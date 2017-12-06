import abc
from collections import namedtuple
from flask_restful import abort
from sqlalchemy import and_, func, or_, UniqueConstraint
from sqlalchemy.exc import ArgumentError
from sqlalchemy.orm import aliased
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql import label
from sqlalchemy.sql import sqltypes as st
from psycopg2.extensions import AsIs

from crime_data.common import models, newmodels
from crime_data.common.models import RefState, RefCounty
from crime_data.common.base import Fields, ExplorerOffenseMapping
from crime_data.extensions import db

session = db.session


def get_sql_count(q):
    """Avoid the slow SQL Alchemy subquery account"""
    count_q = q.statement.with_only_columns([func.count()]).order_by(None)
    count = q.session.execute(count_q).scalar()
    return count


class CdeRefAgencyCounty(models.RefAgencyCounty):
    """A wrapper around the RefAgencyCounty model"""

    @staticmethod
    def current_year():
        """Returns the current year for the agency/county mappings."""
        return session.query(func.max(CdeRefAgencyCounty.data_year)).scalar()


# CdeParticipationRecord = namedtuple('CdeParticipationRecord', ['year', 'total_agencies', 'reporting_agencies', 'reporting_rate', 'total_population', 'covered_population'])

class CdeParticipationRate(newmodels.ParticipationRate):
    """Class for querying the cde_participation_rate"""

    def __init__(self, year=None, state_id=None, county_id=None, states=None):
        self.year = year
        self.state_id = state_id
        self.county_id = county_id
        self.states = states

    @property
    def query(self):

        qry = super().query

        if self.state_id:
            qry = qry.filter(newmodels.ParticipationRate.state_id == self.state_id)

        if self.county_id:
            qry = qry.filter(newmodels.ParticipationRate.county_id == self.county_id)

        if self.year:
            qry = qry.filter(newmodels.ParticipationRate.year == self.year)
        if self.states:
            qry = qry.filter(newmodels.ParticipationRate.state_id.in_(self.states))

        return qry


class CdeRefCounty(db.Model):
    """This uses our denormalized cde_counties table"""
    __tablename__ = 'cde_counties'

    def get(county_id=None, fips=None, name=None):
        """Find matching counties by id, fips code or name."""
        query = CdeRefCounty.query

        if county_id:
            query = query.filter(CdeRefCounty.county_id == county_id)
        elif fips:
            query = query.filter(CdeRefCounty.fips == fips)
        elif name:
            query = query.filter(func.lower(CdeRefCounty.county_name) ==
                                 func.lower(name))

        return query

    county_id = db.Column(db.BigInteger, primary_key=True)
    fips = db.Column(db.String(5))
    county_name = db.Column(db.String(100))
    state_id = db.Column(db.SmallInteger)
    state_name = db.Column(db.String(100))
    state_abbr = db.Column(db.String(2))
    current_year = db.Column(db.SmallInteger)
    total_population = db.Column(db.BigInteger)
    total_agencies = db.Column(db.Integer)
    participating_agencies = db.Column(db.Integer)
    nibrs_participating_agencies = db.Column(db.Integer)
    covered_agencies = db.Column(db.Integer)
    participating_population = db.Column(db.BigInteger)


class CdeRefState(db.Model):
    """A wrapper around the RefState model with extra finder methods"""
    __tablename__ = 'cde_states'

    def get(state_id=None, abbr=None, fips=None, states=None):
        """
        A method to find a state by its database ID, postal abbr or FIPS code
        """
        query = CdeRefState.query

        if state_id:
            query = query.filter(CdeRefState.state_id == state_id)
        elif abbr:
            query = query.filter(func.lower(CdeRefState.state_abbr) == func.lower(abbr))
        elif states:
            query = query.filter(CdeRefState.state_id.in_(states))

        return query

    state_id = db.Column(db.SmallInteger, primary_key=True)
    state_name = db.Column(db.String(100))
    state_abbr = db.Column(db.String(2))
    current_year = db.Column(db.SmallInteger)
    total_population = db.Column(db.BigInteger)
    total_agencies = db.Column(db.Integer)
    participating_agencies = db.Column(db.Integer)
    participation_pct = db.Column(db.Numeric(5, 2))
    nibrs_participating_agencies = db.Column(db.Integer)
    nibrs_participation_pct = db.Column(db.Numeric(5, 2))
    covered_agencies = db.Column(db.Integer)
    covered_pct = db.Column(db.Numeric(5, 2))
    participating_population = db.Column(db.BigInteger)
    participating_population_pct = db.Column(db.Numeric(5, 2))
    nibrs_participating_population = db.Column(db.BigInteger)
    nibrs_population_pct = db.Column(db.Numeric(5, 2))
    police_officers = db.Column(db.Integer)
    civilian_employees = db.Column(db.Integer)

    counties = db.relationship('CdeRefCounty',
                               foreign_keys=[CdeRefCounty.state_id],
                               primaryjoin='CdeRefState.state_id==CdeRefCounty.state_id',
                               lazy='dynamic',
                               backref='state')

    @property
    def participation_rates(self):
        return CdeParticipationRate(state_id=self.state_id).query.order_by('year DESC').all()


class CdeRefAgency(models.RefAgency):
    def get(ori=None):
        # Base Query
        query = CdeRefAgency.query

        # Get ONE ORI.
        if ori:
            query = query.filter(CdeRefAgency.ori == ori)

        return query

    pass


def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)


# CountViews
class MultiYearCountView(object):
    """For materialized views that aren't split by year"""

    __abstract__ = True

    VARIABLES = []

    def __init__(self, field, year=None, state_id=None, state_abbr=None, ori=None, as_json=True):

        self.as_json = as_json

        if field is None:
            raise ValueError('You must specify a field for the CountView')

        if field not in self.VARIABLES:
            raise ValueError('Invalid variable "{}" specified for {}'.format(field, self.view_name))

        self.year = year
        self.state_id = state_id

        if state_abbr and state_id is None:
            # Select State ID for State Abbreviation.
            self.state_id = CdeRefState.get(abbr=state_abbr).one().state_id

        self.ori = ori
        self.field = field
        self.national = False
        if self.state_id is None and self.ori is None:
            self.national = True

    def get_field_table(self, field):
        if field in ['weapon_name']:
            return ('nibrs_weapon_type','weapon_name')

        if field in ['method_entry_code']:
            return ('nibrs_method_entry_code','method_entry_code')

        if field in ['num_premises_entered']:
            return ('nibrs_num_premises_entered', 'num_premises_entered')

        if field in ['bias_name']:
            return ('nibrs_bias_list','bias_name')

        if field in ['resident_status_code']:
            return ('nibrs_resident_status_code','resident_status_code')

        if field in ['victim_type_name']:
            return ('nibrs_victim_type','victim_type_name')

        if field in ['offense_name']:
            return ('nibrs_offense_type','offense_name')

        if field in ['location_name']:
            return ('nibrs_location_type','location_name')

        if field in ['prop_desc_name']:
            return ('nibrs_prop_desc_type','prop_desc_name')

        if field in ['ethnicity']:
            return ('nibrs_ethnicity','ethnicity_name')

        if field in ['offender_relationship']:
            return ('nibrs_relationship','relationship_name')
        # if field in ['victim_offender_rel']:
        #     return('', '')

        if field in ['circumstance_name']:
            return ('nibrs_circumstances', 'circumstances_name')

        if field in ['race_code']:
            return ('ref_race','race_code')

        if field in ['sex_code']:
            return ('nibrs_sex_code','sex_code')

        if field in ['age_num']:
            return ('nibrs_age_num','age_num')

        return (None, None)

    @property
    @abc.abstractmethod
    def view_name(self):
        """The subclasses must define a method that tells the base_query which table to use."""
        return

    def query(self, args):
        base_query = None
        qry = None
        param_dict = {}
        try:
            base_query = self.base_query(self.field)

            # this is unescaoed, but not provided as user input_args
            param_dict['view_name'] = AsIs(self.view_name)
            # field is unescaped but validated in constructor
            param_dict['field'] = AsIs(self.field)

            if self.state_id:
                param_dict['state_id'] = self.state_id
            if self.ori:
                param_dict['ori'] = self.ori
                param_dict['view_name'] = AsIs(self.view_name_ori)
            if self.year:
                param_dict['year'] = self.year

            qry = session.execute(base_query, param_dict)
        except Exception as e:
            session.rollback()
            session.close()
            raise e
        return qry

    def base_query(self, field):
        select_query = 'SELECT b.:field, a.count, b.year FROM (SELECT :field , count, year::text'
        from_query = ' FROM :view_name'
        where_query = ' WHERE :field IS NOT NULL'

        if self.state_id:
            where_query += ' AND state_id = :state_id '

        if self.ori:
            where_query += ' AND ori = :ori'

        if self.national:
            where_query += ' AND state_id is NULL'

        if self.year:
            where_query += ' AND year = :year '

        query = select_query + from_query + where_query

        query += ') a '
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years WHERE year::int = :year) c) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years) c) b ON (a.:field = b.:field AND a.year = b.year)'
            query = query + query_gap_fill
        query += ' ORDER by a.year, a.:field'

        if self.as_json:
            query = 'SELECT array_to_json(array_agg(row_to_json(m))) as json_data from ( ' + query + ') m' # nosec
        return query

class OffenderCountView(MultiYearCountView):
    """A class for fetching the counts """

    VARIABLES = ['ethnicity', 'prop_desc_name', 'offense_name',
                 'race_code', 'location_name', 'age_num', 'sex_code']

    @property
    def view_name(self, ori = None):
        """The name of the specific materialized view for this year."""
        return 'offender_counts_states'

    @property
    def view_name_ori(self):
        """The name of the specific materialized view for this year."""
        return 'offender_counts_ori'

class VictimCountView(MultiYearCountView):
    """A class for fetching the counts """

    VARIABLES = ['prop_desc_name', 'offense_name', 'ethnicity',
                 'resident_status_code', 'offender_relationship',
                 'circumstance_name', 'race_code', 'location_name',
                 'age_num', 'sex_code']

    @property
    def view_name(self):
        """The name of the specific materialized view."""
        return 'victim_counts_states'

    @property
    def view_name_ori(self):
        """The name of the specific materialized view."""
        return 'victim_counts_ori'


class OffenseCountView(MultiYearCountView):
    """A class for fetching the counts broken down by offense"""

    VARIABLES = ['weapon_name', 'method_entry_code', 'num_premises_entered', 'location_name', 'offense_name']

    @property
    def view_name(self):
        """The name of the specific materialized view."""
        return 'offense_counts_states'
    @property
    def view_name_ori(self):
        """The name of the specific materialized view."""
        return 'offense_counts_ori'


class HateCrimeCountView(MultiYearCountView):

    VARIABLES = ['bias_name']

    @property
    def view_name(self):
        """The name of the specific materialized view."""
        return 'hc_counts_states'

    @property
    def view_name_ori(self):
        """The name of the specific materialized view."""
        return 'hc_counts_ori'

class CargoTheftCountView(MultiYearCountView):
    """A class for fetching the counts """

    VARIABLES = ['location_name',
                 'offense_name', 'victim_type_name', 'prop_desc_name']

    @property
    def view_name(self):
        """The name of the specific materialized view."""
        return 'ct_counts_states'

    def view_name_ori(self):
        """The name of the specific materialized view."""
        return 'ct_counts_ori'

    def base_query(self, field):

        query = 'SELECT b.:field, a.count, b.year FROM (SELECT :field ,stolen_value::text, recovered_value::text, year::text, count'
        query += ' FROM :view_name '
        where_query = ' WHERE :field IS NOT NULL'

        if self.state_id:
            where_query += ' AND state_id = :state_id '

        if self.ori:
            where_query += ' AND ori = :ori'

        if self.national:
            where_query += ' AND state_id is NULL '

        if self.year:
            where_query += ' AND year = :year '

        query = query + where_query + ') a '
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years WHERE year::int = :year) c) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years) c) b ON (a.:field = b.:field AND a.year = b.year)'
            query = query + query_gap_fill

        query += ' ORDER by b.year, b.:field'
        query = 'SELECT array_to_json(array_agg(row_to_json(m))) as json_data from ( ' + query + ') m' # nosec
        return query


class OffenseSubCountView(object):

    def __init__(self, field, year=None, state_id=None, ori=None,
                 offense_name=None, state_abbr=None, explorer_offense=None, as_json=True):

        self.as_json = as_json

        if field not in self.VARIABLES:
            raise ValueError('Invalid variable "{}" specified for {}'.format(field, self.view_name))
        self.year = year
        self.state_id = state_id

        if state_abbr and state_id is None:
            # Select State ID for State Abbreviation.
            self.state_id = CdeRefState.get(abbr=state_abbr).one().state_id

        self.ori = ori
        self.field = field

        self.explorer_offense = explorer_offense
        self.offense_name = offense_name

        if explorer_offense:
            offenses = ExplorerOffenseMapping(explorer_offense).nibrs_offense
            if isinstance(offenses, str):
                offenses = [offenses]
            self.offense_name = tuple(offenses)
        elif offense_name:
            self.offense_name = (offense_name, )

        self.national = False
        if self.state_id is None and self.ori is None:
            self.national = True

    def get_field_table(self, field):
        if field in ['weapon_name']:
            return ('nibrs_weapon_type','weapon_name')

        if field in ['method_entry_code']:
            return ('nibrs_method_entry_code','method_entry_code')

        if field in ['num_premises_entered']:
            return ('nibrs_num_premises_entered', 'num_premises_entered')

        if field in ['bias_name']:
            return ('nibrs_bias_list','bias_name')

        if field in ['resident_status_code']:
            return ('nibrs_resident_status_code','resident_status_code')

        if field in ['victim_type_name']:
            return ('nibrs_victim_type','victim_type_name')

        if field in ['offense_name']:
            return ('nibrs_offense_type','offense_name')

        if field in ['location_name']:
            return ('nibrs_location_type','location_name')

        if field in ['prop_desc_name']:
            return ('nibrs_prop_desc_type','prop_desc_name')

        if field in ['ethnicity']:
            return ('nibrs_ethnicity','ethnicity_name')

        if field in ['offender_relationship']:
            return ('nibrs_relationship','relationship_name')
        # if field in ['victim_offender_rel']:
        #     return('', '')

        if field in ['circumstance_name']:
            return ('nibrs_circumstances', 'circumstances_name')

        if field in ['race_code']:
            return ('ref_race','race_code')

        if field in ['sex_code']:
            return ('nibrs_sex_code','sex_code')

        if field in ['age_num']:
            return ('nibrs_age_num','age_num')

        return (None, None)

    def query(self, args):
        base_query = None
        qry = None
        param_dict = {}
        try:
            base_query = self.base_query(self.field)

            # this is unescaoed, but not provided as user input_args
            param_dict['view_name'] = AsIs(self.view_name)
            # field is unescaped but validated in constructor
            param_dict['field'] = AsIs(self.field)

            if self.state_id:
                param_dict['state_id'] = self.state_id
            if self.year:
                param_dict['year'] = self.year
            if self.ori:
                param_dict['ori'] = self.ori
                param_dict['view_name'] = AsIs(self.view_name_ori)
            if self.offense_name:
                param_dict['offense_name'] = self.offense_name
            if self.explorer_offense:
                param_dict['explorer_offense'] = self.explorer_offense

            if not param_dict:
                qry = session.execute(base_query)
            else:
                qry = session.execute(base_query, param_dict)

        except Exception as e:
            session.rollback()
            session.close()
            raise e
        return qry

    def base_query(self, field):


        if self.explorer_offense:
            query = 'SELECT b.year, :explorer_offense AS offense_name, b.:field, SUM(a.count)::int AS count from (SELECT year::text, offense_name, :field, count'
        else:
            query = 'SELECT  b.:field, a.count, b.year from (SELECT year::text, offense_name, :field, count'

        query += ' FROM :view_name'
        where_query = ' WHERE :field IS NOT NULL'

        if self.state_id:
            where_query += ' AND state_id = :state_id '

        if self.national:
            where_query += ' AND state_id is NULL '

        if self.ori:
            where_query += ' AND ori = :ori'

        if self.offense_name:
             where_query += ' AND offense_name IN :offense_name'

        if self.year:
            where_query += ' AND year = :year'

        query = query + where_query + ') a '

        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + '  CROSS JOIN (SELECT year::text from nibrs_years WHERE year::int = :year) c) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years) c) b ON (a.:field = b.:field AND a.year = b.year)'
            query = query + query_gap_fill

        if self.explorer_offense:
            query += ' GROUP by b.year, b.:field, offense_name'

        query += ' ORDER by b.year, offense_name, b.:field'
        # Select as JSON.
        if self.as_json:
            query = 'SELECT array_to_json(array_agg(row_to_json(m))) as json_data from ( ' + query + ') m' # nosec

        return query

class OffenseVictimCountView(OffenseSubCountView):
    """This reports subgrouped counts of a field for a given offense"""

    VARIABLES = ['resident_status_code', 'offender_relationship',
                 'circumstance_name', 'ethnicity', 'race_code',
                 'age_num', 'sex_code']

    DISTINCT_VTABLE = 'victim_counts'

    @property
    def view_name(self):
        return 'offense_victim_counts_states'

    @property
    def view_name_ori(self):
        return 'offense_victim_counts_ori'


class OffenseOffenderCountView(OffenseSubCountView):

    VARIABLES = ['ethnicity', 'race_code', 'age_num', 'sex_code']

    DISTINCT_VTABLE = 'offender_counts'

    @property
    def view_name(self):
        return 'offense_offender_counts_states'

    @property
    def view_name_ori(self):
        return 'offense_offender_counts_ori'

class OffenseByOffenseTypeCountView(OffenseSubCountView):
    VARIABLES = ['weapon_name', 'method_entry_code', 'num_premises_entered', 'location_name']

    DISTINCT_VTABLE = 'offense_counts'

    @property
    def view_name(self):
        return 'offense_offense_counts_states'

    @property
    def view_name_ori(self):
        return 'offense_offense_counts_ori'

class OffenseCargoTheftCountView(OffenseSubCountView):

    VARIABLES = ['location_name', 'victim_type_name', 'prop_desc_name']

    def base_query(self, field):
        if self.explorer_offense:
            query = 'SELECT  b.:field, SUM(a.count)::int AS count, SUM(a.stolen_value)::text AS stolen_value, SUM(a.recovered_value)::text AS recovered_value, :explorer_offense AS offense_name, b.year FROM (SELECT year::text, offense_name, :field, '
            query += 'count, stolen_value, recovered_value'
        else:
            query = 'SELECT  b.:field, a.count, b.year, stolen_value, recovered_value, recovered_value FROM (SELECT year::text, offense_name, :field, count, stolen_value::text, recovered_value::text'
        query += ' FROM :view_name'
        where_query = ' WHERE :field IS NOT NULL'

        if self.state_id:
            where_query += ' AND state_id = :state_id '

        if self.national:
            where_query += ' AND state_id is NULL '

        if self.ori:
            where_query += ' AND ori = :ori '

        if self.offense_name:
            where_query += ' AND offense_name IN :offense_name'

        if self.year:
            where_query += ' AND year = :year'

        query = query + where_query + ') a '
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years WHERE year::int  = :year) c) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years) c) b ON (a.:field = b.:field AND a.year = b.year)'
            query = query + query_gap_fill

        if self.explorer_offense:
            query += ' GROUP by b.year, b.:field, offense_name'

        query += ' ORDER by b.year, offense_name, b.:field'
        if self.as_json:
            query = 'SELECT array_to_json(array_agg(row_to_json(m))) as json_data from ( ' + query + ') m' # nosec
        return query

    @property
    def view_name(self):
        return 'offense_ct_counts_states'

    @property
    def view_name_ori(self):
        return 'offense_ct_counts_ori'


class OffenseHateCrimeCountView(OffenseSubCountView):

    VARIABLES = ['bias_name']

    def base_query(self, field):

        if self.explorer_offense:
            query = 'SELECT b.:field,  SUM(a.count)::int AS count, :explorer_offense AS offense_name, b.year FROM (SELECT year::text, offense_name, :field, count'
        else:
            query = 'SELECT b.:field, a.count, b.year FROM (SELECT year::text, offense_name, :field, count'

        query += ' FROM :view_name'
        where_query = ' WHERE :field IS NOT NULL'

        if self.state_id:
            where_query += ' AND state_id = :state_id '

        if self.national:
            where_query += ' AND state_id is NULL '

        if self.ori:
            where_query += ' AND ori = :ori'

        if self.offense_name:
            where_query += ' AND offense_name IN :offense_name'

        if self.year:
            where_query += ' AND year = :year'

        # if self.explorer_offense:
        #     query += ' GROUP by year, :field'

        query = query + where_query + ') a '
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field,c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years WHERE year::int = :year) c) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years) c) b ON (a.:field = b.:field AND a.year = b.year)'
            query = query + query_gap_fill

        if self.explorer_offense:
            query += ' GROUP by b.year, b.:field, offense_name'

        query += ' ORDER by b.year, b.:field'
        if self.as_json:
            query = 'SELECT array_to_json(array_agg(row_to_json(m))) as json_data from ( ' + query + ') m' # nosec
        return query

    @property
    def view_name(self):
        return 'offense_hc_counts_states'

    @property
    def view_name_ori(self):
        return 'offense_hc_counts_ori'

class NIBRSVictimCount(db.Model):
    """Represents Agency Level NIBRS Victim Data"""
    __tablename__ = 'nibrs_victim_count'
    __table_args__ = (UniqueConstraint('offense_name'), )

    def get(ori=None):
        query = NIBRSVictimCount.query

        if ori:
            query = query.filter(func.lower(NIBRSVictimCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    data_year = db.Column(db.Integer)
    offense_name = db.Column(db.String, primary_key=True)
    type_name = db.Column(db.String)
    sex_code = db.Column(db.String(1))
    age_range = db.Column(db.String)
    race_description = db.Column(db.String)
    ethnicity_name = db.Column(db.String)
    location_name = db.Column(db.String)
    count = db.Column(db.Integer)

class NIBRSAgencyVictimDenormCount(db.Model):
    """Represents Agency Level NIBRS Victim Count Data"""
    __tablename__ = 'nibrs_denorm_agency_victim_count'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        print('Here')

        query = NIBRSAgencyVictimDenormCount.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSAgencyVictimDenormSex(db.Model):
    """Represents Agency Level NIBRS Victim Data"""
    __tablename__ = 'nibrs_denorm_agency_victim_sex'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyVictimDenormSex.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormSex.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSAgencyVictimDenormRace(db.Model):
    """Represents Agency Level NIBRS Victim Race Data"""
    __tablename__ = 'nibrs_denorm_agency_victim_race'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyVictimDenormRace.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormRace.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSAgencyVictimDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Victim Ethnicity Data"""
    __tablename__ = 'nibrs_denorm_agency_victim_ethnicity'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyVictimDenormEthnicity.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormEthnicity.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSAgencyVictimDenormAge(db.Model):
    """Represents Agency Level NIBRS Victim Age Data"""
    __tablename__ = 'nibrs_denorm_agency_victim_age'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyVictimDenormAge.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormAge.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    range_0_9 = db.Column(db.Integer)
    range_10_11 = db.Column(db.Integer)
    range_20_29 = db.Column(db.Integer)
    range_30_39 = db.Column(db.Integer)
    range_40_49 = db.Column(db.Integer)
    range_50_59 = db.Column(db.Integer)
    range_60_69 = db.Column(db.Integer)
    range_70_79 = db.Column(db.Integer)
    range_80_89 = db.Column(db.Integer)
    range_90_99 = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSAgencyVictimDenormLocation(db.Model):
    """Represents Agency Level NIBRS Victim Location Data"""
    __tablename__ = 'nibrs_denorm_agency_victim_location'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyVictimDenormLocation.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormLocation.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    Residence_Home = db.Column(db.Integer)
    Parking_Garage__Lot = db.Column(db.Integer)
    Abandoned_Condemned__Structure = db.Column(db.Integer)
    Air__BusTrain_Terminal = db.Column(db.Integer)
    Amusement_Park = db.Column(db.Integer)
    Arena__Stadium__Fairgrounds = db.Column(db.Integer)
    ATM_Separate_from_Bank = db.Column(db.Integer)
    Auto_Dealership = db.Column(db.Integer)
    Bank = db.Column(db.Integer)
    Bar_Nightclub = db.Column(db.Integer)
    Campground = db.Column(db.Integer)
    Church__Synagogue__Temple__Mosque = db.Column(db.Integer)
    Commercial__Office_Building = db.Column(db.Integer)
    Community_Center = db.Column(db.Integer)
    Construction_Site = db.Column(db.Integer)
    Cyberspace = db.Column(db.Integer)
    Daycare_Facility = db.Column(db.Integer)
    Department__Discount_Store = db.Column(db.Integer)
    Dock__Wharf__Shipping_Terminal = db.Column(db.Integer)
    Drug_Store__Doctors_Office__Hospital = db.Column(db.Integer)
    Farm_Facility = db.Column(db.Integer)
    Field__Woods = db.Column(db.Integer)
    Gambling_Facility__Casino__Race_Track = db.Column(db.Integer)
    Government__Public_Building = db.Column(db.Integer)
    Grocery_Store = db.Column(db.Integer)
    Highway__Alley__Street__Sidewalk = db.Column(db.Integer)
    Hotel__Motel = db.Column(db.Integer)
    Industrial_Site = db.Column(db.Integer)
    Jail__Prison__Corrections_Facility = db.Column(db.Integer)
    Lake__Waterway__Beach = db.Column(db.Integer)
    Liquor_Store = db.Column(db.Integer)
    Military_Base = db.Column(db.Integer)
    Unknown = db.Column(db.Integer)
    Park__Playground = db.Column(db.Integer)
    Rental_Storage_Facility = db.Column(db.Integer)
    Rest_Area = db.Column(db.Integer)
    Restaurant = db.Column(db.Integer)
    School__College = db.Column(db.Integer)
    School_College__University = db.Column(db.Integer)
    School_Elementary__Secondary = db.Column(db.Integer)
    Gas_Station = db.Column(db.Integer)
    Mission__Homeless_Shelter = db.Column(db.Integer)
    Shopping_Mall = db.Column(db.Integer)
    Specialty_Store = db.Column(db.Integer)
    Tribal_Lands = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateVictimDenormCount(db.Model):
    """Represents Agency Level NIBRS Victim Count Data"""
    __tablename__ = 'nibrs_denorm_state_victim_count'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        print('Here')

        query = NIBRSStateVictimDenormCount.query

        if ori:
            query = query.filter(func.lower(NIBRSStateVictimDenormCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateVictimDenormSex(db.Model):
    """Represents Agency Level NIBRS Victim Data"""
    __tablename__ = 'nibrs_denorm_state_victim_sex'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateVictimDenormSex.query

        if ori:
            query = query.filter(func.lower(NIBRSStateVictimDenormSex.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateVictimDenormRace(db.Model):
    """Represents Agency Level NIBRS Victim Race Data"""
    __tablename__ = 'nibrs_denorm_state_victim_race'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateVictimDenormRace.query

        if ori:
            query = query.filter(func.lower(NIBRSStateVictimDenormRace.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateVictimDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Victim Ethnicity Data"""
    __tablename__ = 'nibrs_denorm_state_victim_ethnicity'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateVictimDenormEthnicity.query

        if ori:
            query = query.filter(func.lower(NIBRSStateVictimDenormEthnicity.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSStateVictimDenormAge(db.Model):
    """Represents Agency Level NIBRS Victim Age Data"""
    __tablename__ = 'nibrs_denorm_state_victim_age'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateVictimDenormAge.query

        if ori:
            query = query.filter(func.lower(NIBRSStateVictimDenormAge.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    range_0_9 = db.Column(db.Integer)
    range_10_11 = db.Column(db.Integer)
    range_20_29 = db.Column(db.Integer)
    range_30_39 = db.Column(db.Integer)
    range_40_49 = db.Column(db.Integer)
    range_50_59 = db.Column(db.Integer)
    range_60_69 = db.Column(db.Integer)
    range_70_79 = db.Column(db.Integer)
    range_80_89 = db.Column(db.Integer)
    range_90_99 = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateVictimDenormLocation(db.Model):
    """Represents Agency Level NIBRS Victim Location Data"""
    __tablename__ = 'nibrs_denorm_state_victim_location'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateVictimDenormLocation.query

        if ori:
            query = query.filter(func.lower(NIBRSStateVictimDenormLocation.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    Residence_Home = db.Column(db.Integer)
    Parking_Garage__Lot = db.Column(db.Integer)
    Abandoned_Condemned__Structure = db.Column(db.Integer)
    Air__BusTrain_Terminal = db.Column(db.Integer)
    Amusement_Park = db.Column(db.Integer)
    Arena__Stadium__Fairgrounds = db.Column(db.Integer)
    ATM_Separate_from_Bank = db.Column(db.Integer)
    Auto_Dealership = db.Column(db.Integer)
    Bank = db.Column(db.Integer)
    Bar_Nightclub = db.Column(db.Integer)
    Campground = db.Column(db.Integer)
    Church__Synagogue__Temple__Mosque = db.Column(db.Integer)
    Commercial__Office_Building = db.Column(db.Integer)
    Community_Center = db.Column(db.Integer)
    Construction_Site = db.Column(db.Integer)
    Cyberspace = db.Column(db.Integer)
    Daycare_Facility = db.Column(db.Integer)
    Department__Discount_Store = db.Column(db.Integer)
    Dock__Wharf__Shipping_Terminal = db.Column(db.Integer)
    Drug_Store__Doctors_Office__Hospital = db.Column(db.Integer)
    Farm_Facility = db.Column(db.Integer)
    Field__Woods = db.Column(db.Integer)
    Gambling_Facility__Casino__Race_Track = db.Column(db.Integer)
    Government__Public_Building = db.Column(db.Integer)
    Grocery_Store = db.Column(db.Integer)
    Highway__Alley__Street__Sidewalk = db.Column(db.Integer)
    Hotel__Motel = db.Column(db.Integer)
    Industrial_Site = db.Column(db.Integer)
    Jail__Prison__Corrections_Facility = db.Column(db.Integer)
    Lake__Waterway__Beach = db.Column(db.Integer)
    Liquor_Store = db.Column(db.Integer)
    Military_Base = db.Column(db.Integer)
    Unknown = db.Column(db.Integer)
    Park__Playground = db.Column(db.Integer)
    Rental_Storage_Facility = db.Column(db.Integer)
    Rest_Area = db.Column(db.Integer)
    Restaurant = db.Column(db.Integer)
    School__College = db.Column(db.Integer)
    School_College__University = db.Column(db.Integer)
    School_Elementary__Secondary = db.Column(db.Integer)
    Gas_Station = db.Column(db.Integer)
    Mission__Homeless_Shelter = db.Column(db.Integer)
    Shopping_Mall = db.Column(db.Integer)
    Specialty_Store = db.Column(db.Integer)
    Tribal_Lands = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalVictimDenormCount(db.Model):
    """Represents Agency Level NIBRS Victim Count Data"""
    __tablename__ = 'nibrs_denorm_national_victim_count'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        print('Here')

        query = NIBRSNationalVictimDenormCount.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalVictimDenormCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalVictimDenormSex(db.Model):
    """Represents Agency Level NIBRS Victim Data"""
    __tablename__ = 'nibrs_denorm_national_victim_sex'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalVictimDenormSex.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalVictimDenormSex.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalVictimDenormRace(db.Model):
    """Represents Agency Level NIBRS Victim Race Data"""
    __tablename__ = 'nibrs_denorm_national_victim_race'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalVictimDenormRace.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalVictimDenormRace.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalVictimDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Victim Ethnicity Data"""
    __tablename__ = 'nibrs_denorm_national_victim_ethnicity'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalVictimDenormEthnicity.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalVictimDenormEthnicity.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSNationalVictimDenormAge(db.Model):
    """Represents Agency Level NIBRS Victim Age Data"""
    __tablename__ = 'nibrs_denorm_national_victim_age'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalVictimDenormAge.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalVictimDenormAge.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    range_0_9 = db.Column(db.Integer)
    range_10_11 = db.Column(db.Integer)
    range_20_29 = db.Column(db.Integer)
    range_30_39 = db.Column(db.Integer)
    range_40_49 = db.Column(db.Integer)
    range_50_59 = db.Column(db.Integer)
    range_60_69 = db.Column(db.Integer)
    range_70_79 = db.Column(db.Integer)
    range_80_89 = db.Column(db.Integer)
    range_90_99 = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalVictimDenormLocation(db.Model):
    """Represents Agency Level NIBRS Victim Location Data"""
    __tablename__ = 'nibrs_denorm_national_victim_location'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalVictimDenormLocation.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalVictimDenormLocation.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    Residence_Home = db.Column(db.Integer)
    Parking_Garage__Lot = db.Column(db.Integer)
    Abandoned_Condemned__Structure = db.Column(db.Integer)
    Air__BusTrain_Terminal = db.Column(db.Integer)
    Amusement_Park = db.Column(db.Integer)
    Arena__Stadium__Fairgrounds = db.Column(db.Integer)
    ATM_Separate_from_Bank = db.Column(db.Integer)
    Auto_Dealership = db.Column(db.Integer)
    Bank = db.Column(db.Integer)
    Bar_Nightclub = db.Column(db.Integer)
    Campground = db.Column(db.Integer)
    Church__Synagogue__Temple__Mosque = db.Column(db.Integer)
    Commercial__Office_Building = db.Column(db.Integer)
    Community_Center = db.Column(db.Integer)
    Construction_Site = db.Column(db.Integer)
    Cyberspace = db.Column(db.Integer)
    Daycare_Facility = db.Column(db.Integer)
    Department__Discount_Store = db.Column(db.Integer)
    Dock__Wharf__Shipping_Terminal = db.Column(db.Integer)
    Drug_Store__Doctors_Office__Hospital = db.Column(db.Integer)
    Farm_Facility = db.Column(db.Integer)
    Field__Woods = db.Column(db.Integer)
    Gambling_Facility__Casino__Race_Track = db.Column(db.Integer)
    Government__Public_Building = db.Column(db.Integer)
    Grocery_Store = db.Column(db.Integer)
    Highway__Alley__Street__Sidewalk = db.Column(db.Integer)
    Hotel__Motel = db.Column(db.Integer)
    Industrial_Site = db.Column(db.Integer)
    Jail__Prison__Corrections_Facility = db.Column(db.Integer)
    Lake__Waterway__Beach = db.Column(db.Integer)
    Liquor_Store = db.Column(db.Integer)
    Military_Base = db.Column(db.Integer)
    Unknown = db.Column(db.Integer)
    Park__Playground = db.Column(db.Integer)
    Rental_Storage_Facility = db.Column(db.Integer)
    Rest_Area = db.Column(db.Integer)
    Restaurant = db.Column(db.Integer)
    School__College = db.Column(db.Integer)
    School_College__University = db.Column(db.Integer)
    School_Elementary__Secondary = db.Column(db.Integer)
    Gas_Station = db.Column(db.Integer)
    Mission__Homeless_Shelter = db.Column(db.Integer)
    Shopping_Mall = db.Column(db.Integer)
    Specialty_Store = db.Column(db.Integer)
    Tribal_Lands = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSOffenderCount(db.Model):
    """Represents Agency Level NIBRS Offender Data"""
    __tablename__ = 'nibrs_Offender_count'
    __table_args__ = (UniqueConstraint('offense_name'), )

    def get(ori=None):
        query = NIBRSOffenderCount.query

        if ori:
            query = query.filter(func.lower(NIBRSOffenderCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    data_year = db.Column(db.Integer)
    offense_name = db.Column(db.String, primary_key=True)
    type_name = db.Column(db.String)
    sex_code = db.Column(db.String(1))
    age_range = db.Column(db.String)
    race_description = db.Column(db.String)
    ethnicity_name = db.Column(db.String)
    location_name = db.Column(db.String)
    count = db.Column(db.Integer)

class NIBRSAgencyOffenderDenormCount(db.Model):
    """Represents Agency Level NIBRS Offender Count Data"""
    __tablename__ = 'nibrs_denorm_agency_Offender_count'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormCount.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSAgencyOffenderDenormSex(db.Model):
    """Represents Agency Level NIBRS Offender Data"""
    __tablename__ = 'nibrs_denorm_agency_Offender_sex'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormSex.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormSex.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSAgencyOffenderDenormRace(db.Model):
    """Represents Agency Level NIBRS Offender Race Data"""
    __tablename__ = 'nibrs_denorm_agency_Offender_race'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormRace.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormRace.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSAgencyOffenderDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Offender Ethnicity Data"""
    __tablename__ = 'nibrs_denorm_agency_Offender_ethnicity'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormEthnicity.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormEthnicity.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSAgencyOffenderDenormAge(db.Model):
    """Represents Agency Level NIBRS Offender Age Data"""
    __tablename__ = 'nibrs_denorm_agency_Offender_age'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormAge.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormAge.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    range_0_9 = db.Column(db.Integer)
    range_10_11 = db.Column(db.Integer)
    range_20_29 = db.Column(db.Integer)
    range_30_39 = db.Column(db.Integer)
    range_40_49 = db.Column(db.Integer)
    range_50_59 = db.Column(db.Integer)
    range_60_69 = db.Column(db.Integer)
    range_70_79 = db.Column(db.Integer)
    range_80_89 = db.Column(db.Integer)
    range_90_99 = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateOffenderDenormCount(db.Model):
    """Represents Agency Level NIBRS Offender Count Data"""
    __tablename__ = 'nibrs_denorm_state_Offender_count'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateOffenderDenormCount.query

        if ori:
            query = query.filter(func.lower(NIBRSStateOffenderDenormCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateOffenderDenormSex(db.Model):
    """Represents Agency Level NIBRS Offender Data"""
    __tablename__ = 'nibrs_denorm_state_Offender_sex'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateOffenderDenormSex.query

        if ori:
            query = query.filter(func.lower(NIBRSStateOffenderDenormSex.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateOffenderDenormRace(db.Model):
    """Represents Agency Level NIBRS Offender Race Data"""
    __tablename__ = 'nibrs_denorm_state_Offender_race'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateOffenderDenormRace.query

        if ori:
            query = query.filter(func.lower(NIBRSStateOffenderDenormRace.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateOffenderDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Offender Ethnicity Data"""
    __tablename__ = 'nibrs_denorm_state_Offender_ethnicity'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateOffenderDenormEthnicity.query

        if ori:
            query = query.filter(func.lower(NIBRSStateOffenderDenormEthnicity.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSStateOffenderDenormAge(db.Model):
    """Represents Agency Level NIBRS Offender Age Data"""
    __tablename__ = 'nibrs_denorm_state_Offender_age'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSStateOffenderDenormAge.query

        if ori:
            query = query.filter(func.lower(NIBRSStateOffenderDenormAge.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    range_0_9 = db.Column(db.Integer)
    range_10_11 = db.Column(db.Integer)
    range_20_29 = db.Column(db.Integer)
    range_30_39 = db.Column(db.Integer)
    range_40_49 = db.Column(db.Integer)
    range_50_59 = db.Column(db.Integer)
    range_60_69 = db.Column(db.Integer)
    range_70_79 = db.Column(db.Integer)
    range_80_89 = db.Column(db.Integer)
    range_90_99 = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalOffenderDenormCount(db.Model):
    """Represents Agency Level NIBRS Offender Count Data"""
    __tablename__ = 'nibrs_denorm_national_Offender_count'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalOffenderDenormCount.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalOffenderDenormCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalOffenderDenormSex(db.Model):
    """Represents Agency Level NIBRS Offender Data"""
    __tablename__ = 'nibrs_denorm_national_Offender_sex'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalOffenderDenormSex.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalOffenderDenormSex.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalOffenderDenormRace(db.Model):
    """Represents Agency Level NIBRS Offender Race Data"""
    __tablename__ = 'nibrs_denorm_national_Offender_race'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalOffenderDenormRace.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalOffenderDenormRace.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalOffenderDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Offender Ethnicity Data"""
    __tablename__ = 'nibrs_denorm_national_Offender_ethnicity'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalOffenderDenormEthnicity.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalOffenderDenormEthnicity.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSNationalOffenderDenormAge(db.Model):
    """Represents Agency Level NIBRS Offender Age Data"""
    __tablename__ = 'nibrs_denorm_national_Offender_age'
    __table_args__ = (UniqueConstraint('offense_name'), )
    def get(ori=None):
        query = NIBRSNationalOffenderDenormAge.query

        if ori:
            query = query.filter(func.lower(NIBRSNationalOffenderDenormAge.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String, primary_key=True)
    range_0_9 = db.Column(db.Integer)
    range_10_11 = db.Column(db.Integer)
    range_20_29 = db.Column(db.Integer)
    range_30_39 = db.Column(db.Integer)
    range_40_49 = db.Column(db.Integer)
    range_50_59 = db.Column(db.Integer)
    range_60_69 = db.Column(db.Integer)
    range_70_79 = db.Column(db.Integer)
    range_80_89 = db.Column(db.Integer)
    range_90_99 = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)
