import abc
from collections import namedtuple
from flask_restful import abort
from sqlalchemy import and_, func, or_, UniqueConstraint, PrimaryKeyConstraint, Index
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
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    def get(ori=None):
        query = NIBRSVictimCount.query

        if ori:
            query = query.filter(func.lower(NIBRSVictimCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    data_year = db.Column(db.Integer)
    offense_name = db.Column(db.String)
    type_name = db.Column(db.String)
    sex_code = db.Column(db.String(1))
    age_range = db.Column(db.String)
    race_description = db.Column(db.String)
    ethnicity_name = db.Column(db.String)
    location_name = db.Column(db.String)
    count = db.Column(db.Integer)

class NIBRSAgencyVictimDenormCount(db.Model):
    """Represents Agency Level NIBRS Victim Count Data"""
    __tablename__ = 'nibrs_agency_denorm_victim_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        print('Here')

        query = NIBRSAgencyVictimDenormCount.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyVictimDenormCount_index = Index('ori_index_nibrs_agency_denorm_victim_count', NIBRSAgencyVictimDenormCount.ori)

class NIBRSAgencyVictimDenormSex(db.Model):
    """Represents Agency Level NIBRS Victim Data"""
    __tablename__ = 'nibrs_agency_denorm_victim_sex'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyVictimDenormSex.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormSex.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyVictimDenormSex_index = Index('ori_index_nibrs_agency_denorm_victim_sex', NIBRSAgencyVictimDenormSex.ori)

class NIBRSAgencyVictimDenormRace(db.Model):
    """Represents Agency Level NIBRS Victim Race Data"""
    __tablename__ = 'nibrs_agency_denorm_victim_race'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyVictimDenormRace.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormRace.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyVictimDenormRace_index = Index('ori_index_nibrs_agency_denorm_victim_race', NIBRSAgencyVictimDenormRace.ori)


class NIBRSAgencyVictimDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Victim Ethnicity Data"""
    __tablename__ = 'nibrs_agency_denorm_victim_ethnicity'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyVictimDenormEthnicity.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormEthnicity.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyVictimDenormEthnicity_index = Index('ori_index_nibrs_agency_denorm_victim_ethnicity', NIBRSAgencyVictimDenormEthnicity.ori)


class NIBRSAgencyVictimDenormAge(db.Model):
    """Represents Agency Level NIBRS Victim Age Data"""
    __tablename__ = 'nibrs_agency_denorm_victim_age'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyVictimDenormAge.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormAge.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    range_0_9 = db.Column(db.Integer)
    range_10_19 = db.Column(db.Integer)
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

NIBRSAgencyVictimDenormAge_index = Index('ori_index_nibrs_agency_denorm_victim_age', NIBRSAgencyVictimDenormAge.ori)


class NIBRSAgencyVictimDenormLocation(db.Model):
    """Represents Agency Level NIBRS Victim Location Data"""
    __tablename__ = 'nibrs_agency_denorm_victim_location'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )

    def get(ori=None):
        query = NIBRSAgencyVictimDenormLocation.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyVictimDenormLocation.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    residence_home = db.Column(db.Integer)
    parking_garage__lot = db.Column(db.Integer)
    abandoned_condemned__structure = db.Column(db.Integer)
    air__bus__train_terminal = db.Column(db.Integer)
    amusement_park = db.Column(db.Integer)
    arena__stadium__fairgrounds = db.Column(db.Integer)
    atm_separate_from_bank = db.Column(db.Integer)
    auto_dealership = db.Column(db.Integer)
    bank = db.Column(db.Integer)
    bar_nightclub = db.Column(db.Integer)
    campground = db.Column(db.Integer)
    church__synagogue__temple__mosque = db.Column(db.Integer)
    commercial__office_building = db.Column(db.Integer)
    community_center = db.Column(db.Integer)
    construction_site = db.Column(db.Integer)
    cyberspace = db.Column(db.Integer)
    daycare_facility = db.Column(db.Integer)
    department__discount_store = db.Column(db.Integer)
    dock__wharf__shipping_terminal = db.Column(db.Integer)
    drug_store__doctors_office__hospital = db.Column(db.Integer)
    farm_facility = db.Column(db.Integer)
    field__woods = db.Column(db.Integer)
    gambling_facility__casino__race_track = db.Column(db.Integer)
    government__public_building = db.Column(db.Integer)
    grocery_store = db.Column(db.Integer)
    highway__alley__street__sidewalk = db.Column(db.Integer)
    hotel__motel = db.Column(db.Integer)
    industrial_site = db.Column(db.Integer)
    jail__prison__corrections_facility = db.Column(db.Integer)
    lake__waterway__beach = db.Column(db.Integer)
    liquor_store = db.Column(db.Integer)
    military_base = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    park__playground = db.Column(db.Integer)
    rental_storage_facility = db.Column(db.Integer)
    rest_area = db.Column(db.Integer)
    restaurant = db.Column(db.Integer)
    school__college = db.Column(db.Integer)
    school_college__university = db.Column(db.Integer)
    school_elementary__secondary = db.Column(db.Integer)
    gas_station = db.Column(db.Integer)
    mission__homeless_shelter = db.Column(db.Integer)
    shopping_mall = db.Column(db.Integer)
    specialty_store = db.Column(db.Integer)
    tribal_lands = db.Column(db.Integer)
    convenience_store = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyVictimDenormLocation_index = Index('ori_index_nibrs_agency_denorm_victim_location', NIBRSAgencyVictimDenormLocation.ori)


class NIBRSStateVictimDenormCount(db.Model):
    """Represents Agency Level NIBRS Victim Count Data"""
    __tablename__ = 'nibrs_state_denorm_victim_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateVictimDenormCount.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateVictimDenormCount.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateVictimDenormSex(db.Model):
    """Represents Agency Level NIBRS Victim Data"""
    __tablename__ = 'nibrs_state_denorm_victim_sex'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateVictimDenormSex.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateVictimDenormSex.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateVictimDenormRace(db.Model):
    """Represents Agency Level NIBRS Victim Race Data"""
    __tablename__ = 'nibrs_state_denorm_victim_race'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateVictimDenormRace.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateVictimDenormRace.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateVictimDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Victim Ethnicity Data"""
    __tablename__ = 'nibrs_state_denorm_victim_ethnicity'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateVictimDenormEthnicity.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateVictimDenormEthnicity.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSStateVictimDenormAge(db.Model):
    """Represents Agency Level NIBRS Victim Age Data"""
    __tablename__ = 'nibrs_state_denorm_victim_age'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateVictimDenormAge.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateVictimDenormAge.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    range_0_9 = db.Column(db.Integer)
    range_10_19 = db.Column(db.Integer)
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
    __tablename__ = 'nibrs_state_denorm_victim_location'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateVictimDenormLocation.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateVictimDenormLocation.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    residence_home = db.Column(db.Integer)
    parking_garage__lot = db.Column(db.Integer)
    abandoned_condemned__structure = db.Column(db.Integer)
    air__bus__train_terminal = db.Column(db.Integer)
    amusement_park = db.Column(db.Integer)
    arena__stadium__fairgrounds = db.Column(db.Integer)
    atm_separate_from_bank = db.Column(db.Integer)
    auto_dealership = db.Column(db.Integer)
    bank = db.Column(db.Integer)
    bar_nightclub = db.Column(db.Integer)
    campground = db.Column(db.Integer)
    church__synagogue__temple__mosque = db.Column(db.Integer)
    commercial__office_building = db.Column(db.Integer)
    community_center = db.Column(db.Integer)
    construction_site = db.Column(db.Integer)
    cyberspace = db.Column(db.Integer)
    daycare_facility = db.Column(db.Integer)
    department__discount_store = db.Column(db.Integer)
    dock__wharf__shipping_terminal = db.Column(db.Integer)
    drug_store__doctors_office__hospital = db.Column(db.Integer)
    farm_facility = db.Column(db.Integer)
    field__woods = db.Column(db.Integer)
    gambling_facility__casino__race_track = db.Column(db.Integer)
    government__public_building = db.Column(db.Integer)
    grocery_store = db.Column(db.Integer)
    highway__alley__street__sidewalk = db.Column(db.Integer)
    hotel__motel = db.Column(db.Integer)
    industrial_site = db.Column(db.Integer)
    jail__prison__corrections_facility = db.Column(db.Integer)
    lake__waterway__beach = db.Column(db.Integer)
    liquor_store = db.Column(db.Integer)
    military_base = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    park__playground = db.Column(db.Integer)
    rental_storage_facility = db.Column(db.Integer)
    rest_area = db.Column(db.Integer)
    restaurant = db.Column(db.Integer)
    school__college = db.Column(db.Integer)
    school_college__university = db.Column(db.Integer)
    school_elementary__secondary = db.Column(db.Integer)
    gas_station = db.Column(db.Integer)
    mission__homeless_shelter = db.Column(db.Integer)
    shopping_mall = db.Column(db.Integer)
    specialty_store = db.Column(db.Integer)
    tribal_lands = db.Column(db.Integer)
    convenience_store = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalVictimDenormCount(db.Model):
    """Represents Agency Level NIBRS Victim Count Data"""
    __tablename__ = 'nibrs_national_denorm_victim_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalVictimDenormSex(db.Model):
    """Represents Agency Level NIBRS Victim Data"""
    __tablename__ = 'nibrs_national_denorm_victim_sex'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalVictimDenormRace(db.Model):
    """Represents Agency Level NIBRS Victim Race Data"""
    __tablename__ = 'nibrs_national_denorm_victim_race'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalVictimDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Victim Ethnicity Data"""
    __tablename__ = 'nibrs_national_denorm_victim_ethnicity'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSNationalVictimDenormAge(db.Model):
    """Represents Agency Level NIBRS Victim Age Data"""
    __tablename__ = 'nibrs_national_denorm_victim_age'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    range_0_9 = db.Column(db.Integer)
    range_10_19 = db.Column(db.Integer)
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
    __tablename__ = 'nibrs_national_denorm_victim_location'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    residence_home = db.Column(db.Integer)
    parking_garage__lot = db.Column(db.Integer)
    abandoned_condemned__structure = db.Column(db.Integer)
    air__bus__train_terminal = db.Column(db.Integer)
    amusement_park = db.Column(db.Integer)
    arena__stadium__fairgrounds = db.Column(db.Integer)
    atm_separate_from_bank = db.Column(db.Integer)
    auto_dealership = db.Column(db.Integer)
    bank = db.Column(db.Integer)
    bar_nightclub = db.Column(db.Integer)
    campground = db.Column(db.Integer)
    church__synagogue__temple__mosque = db.Column(db.Integer)
    commercial__office_building = db.Column(db.Integer)
    community_center = db.Column(db.Integer)
    construction_site = db.Column(db.Integer)
    cyberspace = db.Column(db.Integer)
    daycare_facility = db.Column(db.Integer)
    department__discount_store = db.Column(db.Integer)
    dock__wharf__shipping_terminal = db.Column(db.Integer)
    drug_store__doctors_office__hospital = db.Column(db.Integer)
    farm_facility = db.Column(db.Integer)
    field__woods = db.Column(db.Integer)
    gambling_facility__casino__race_track = db.Column(db.Integer)
    government__public_building = db.Column(db.Integer)
    grocery_store = db.Column(db.Integer)
    highway__alley__street__sidewalk = db.Column(db.Integer)
    hotel__motel = db.Column(db.Integer)
    industrial_site = db.Column(db.Integer)
    jail__prison__corrections_facility = db.Column(db.Integer)
    lake__waterway__beach = db.Column(db.Integer)
    liquor_store = db.Column(db.Integer)
    military_base = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    park__playground = db.Column(db.Integer)
    rental_storage_facility = db.Column(db.Integer)
    rest_area = db.Column(db.Integer)
    restaurant = db.Column(db.Integer)
    school__college = db.Column(db.Integer)
    school_college__university = db.Column(db.Integer)
    school_elementary__secondary = db.Column(db.Integer)
    gas_station = db.Column(db.Integer)
    mission__homeless_shelter = db.Column(db.Integer)
    shopping_mall = db.Column(db.Integer)
    specialty_store = db.Column(db.Integer)
    tribal_lands = db.Column(db.Integer)
    convenience_store = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSOffenderCount(db.Model):
    """Represents Agency Level NIBRS Offender Data"""
    __tablename__ = 'nibrs_offender_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    def get(ori=None):
        query = NIBRSOffenderCount.query

        if ori:
            query = query.filter(func.lower(NIBRSOffenderCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    data_year = db.Column(db.Integer)
    offense_name = db.Column(db.String)
    type_name = db.Column(db.String)
    sex_code = db.Column(db.String(1))
    age_range = db.Column(db.String)
    race_description = db.Column(db.String)
    ethnicity_name = db.Column(db.String)
    location_name = db.Column(db.String)
    count = db.Column(db.Integer)

class NIBRSAgencyOffenderDenormCount(db.Model):
    """Represents Agency Level NIBRS Offender Count Data"""
    __tablename__ = 'nibrs_agency_denorm_offender_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormCount.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormCount.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyOffenderDenormCount_index = Index('ori_index_nibrs_agency_denorm_offender_count', NIBRSAgencyOffenderDenormCount.ori)


class NIBRSAgencyOffenderDenormSex(db.Model):
    """Represents Agency Level NIBRS Offender Data"""
    __tablename__ = 'nibrs_agency_denorm_offender_sex'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormSex.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormSex.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyOffenderDenormSex_index = Index('ori_index_nibrs_agency_denorm_offender_sex', NIBRSAgencyOffenderDenormSex.ori)


class NIBRSAgencyOffenderDenormRace(db.Model):
    """Represents Agency Level NIBRS Offender Race Data"""
    __tablename__ = 'nibrs_agency_denorm_offender_race'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormRace.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormRace.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyOffenderDenormRace_index = Index('ori_index_nibrs_agency_denorm_offender_race', NIBRSAgencyOffenderDenormRace.ori)



class NIBRSAgencyOffenderDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Offender Ethnicity Data"""
    __tablename__ = 'nibrs_agency_denorm_offender_ethnicity'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormEthnicity.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormEthnicity.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyOffenderDenormEthnicity_index = Index('ori_index_nibrs_agency_denorm_offender_ethnicity', NIBRSAgencyOffenderDenormEthnicity.ori)



class NIBRSAgencyOffenderDenormAge(db.Model):
    """Represents Agency Level NIBRS Offender Age Data"""
    __tablename__ = 'nibrs_agency_denorm_offender_age'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyOffenderDenormAge.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenderDenormAge.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    range_0_9 = db.Column(db.Integer)
    range_10_19 = db.Column(db.Integer)
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

NIBRSAgencyOffenderDenormAge_index = Index('ori_index_nibrs_agency_denorm_offender_age', NIBRSAgencyOffenderDenormAge.ori)


class NIBRSStateOffenderDenormCount(db.Model):
    """Represents Agency Level NIBRS Offender Count Data"""
    __tablename__ = 'nibrs_state_denorm_offender_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateOffenderDenormCount.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateOffenderDenormCount.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateOffenderDenormSex(db.Model):
    """Represents Agency Level NIBRS Offender Data"""
    __tablename__ = 'nibrs_state_denorm_offender_sex'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateOffenderDenormSex.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateOffenderDenormSex.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateOffenderDenormRace(db.Model):
    """Represents Agency Level NIBRS Offender Race Data"""
    __tablename__ = 'nibrs_state_denorm_offender_race'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateOffenderDenormRace.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateOffenderDenormRace.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSStateOffenderDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Offender Ethnicity Data"""
    __tablename__ = 'nibrs_state_denorm_offender_ethnicity'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateOffenderDenormEthnicity.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateOffenderDenormEthnicity.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSStateOffenderDenormAge(db.Model):
    """Represents Agency Level NIBRS Offender Age Data"""
    __tablename__ = 'nibrs_state_denorm_offender_age'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateOffenderDenormAge.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateOffenderDenormAge.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    range_0_9 = db.Column(db.Integer)
    range_10_19 = db.Column(db.Integer)
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
    __tablename__ = 'nibrs_national_denorm_offender_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalOffenderDenormSex(db.Model):
    """Represents Agency Level NIBRS Offender Data"""
    __tablename__ = 'nibrs_national_denorm_offender_sex'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    male_count = db.Column(db.Integer)
    female_count = db.Column(db.Integer)
    unknown_count = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalOffenderDenormRace(db.Model):
    """Represents Agency Level NIBRS Offender Race Data"""
    __tablename__ = 'nibrs_national_denorm_offender_race'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    asian = db.Column(db.Integer)
    native_hawaiian = db.Column(db.Integer)
    black = db.Column(db.Integer)
    american_indian = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

class NIBRSNationalOffenderDenormEthnicity(db.Model):
    """Represents Agency Level NIBRS Offender Ethnicity Data"""
    __tablename__ = 'nibrs_national_denorm_offender_ethnicity'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    hispanic = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_hispanic = db.Column(db.Integer)
    unknown = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSNationalOffenderDenormAge(db.Model):
    """Represents Agency Level NIBRS Offender Age Data"""
    __tablename__ = 'nibrs_national_denorm_offender_age'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    range_0_9 = db.Column(db.Integer)
    range_10_19 = db.Column(db.Integer)
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

class NIBRSNationalDenormVictimOffenderRelationship(db.Model):
    """Represents Agency Level NIBRS Offender Data"""
    __tablename__ = 'nibrs_national_denorm_victim_offender_relationship'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    acquaintance = db.Column(db.Integer)
    babysittee = db.Column(db.Integer)
    boyfriend_girlfriend = db.Column(db.Integer)
    child_boyfriend_girlfriend = db.Column(db.Integer)
    child = db.Column(db.Integer)
    common_law_spouse = db.Column(db.Integer)
    employee = db.Column(db.Integer)
    employer = db.Column(db.Integer)
    friend = db.Column(db.Integer)
    grandchild = db.Column(db.Integer)
    grandparent = db.Column(db.Integer)
    homosexual_relationship = db.Column(db.Integer)
    in_law = db.Column(db.Integer)
    neighbor = db.Column(db.Integer)
    other_family_member = db.Column(db.Integer)
    otherwise_known = db.Column(db.Integer)
    parent = db.Column(db.Integer)
    relationship_unknown = db.Column(db.Integer)
    sibling = db.Column(db.Integer)
    stepchild = db.Column(db.Integer)
    spouse = db.Column(db.Integer)
    stepparent = db.Column(db.Integer)
    stepsibling = db.Column(db.Integer)
    stranger = db.Column(db.Integer)
    offender = db.Column(db.Integer)
    ex_spouse = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSAgencyDenormVictimOffenderRelationship(db.Model):
    """Represents Agency Level NIBRS Victim Data"""
    __tablename__ = 'nibrs_agency_denorm_victim_offender_relationship'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyDenormVictimOffenderRelationship.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyDenormVictimOffenderRelationship.ori) == func.lower(ori))

        return query

    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    offense_name = db.Column(db.String)
    acquaintance = db.Column(db.Integer)
    babysittee = db.Column(db.Integer)
    boyfriend_girlfriend = db.Column(db.Integer)
    child_boyfriend_girlfriend = db.Column(db.Integer)
    child = db.Column(db.Integer)
    common_law_spouse = db.Column(db.Integer)
    employee = db.Column(db.Integer)
    employer = db.Column(db.Integer)
    friend = db.Column(db.Integer)
    grandchild = db.Column(db.Integer)
    grandparent = db.Column(db.Integer)
    homosexual_relationship = db.Column(db.Integer)
    in_law = db.Column(db.Integer)
    neighbor = db.Column(db.Integer)
    other_family_member = db.Column(db.Integer)
    otherwise_known = db.Column(db.Integer)
    parent = db.Column(db.Integer)
    relationship_unknown = db.Column(db.Integer)
    sibling = db.Column(db.Integer)
    stepchild = db.Column(db.Integer)
    spouse = db.Column(db.Integer)
    stepparent = db.Column(db.Integer)
    stepsibling = db.Column(db.Integer)
    stranger = db.Column(db.Integer)
    offender = db.Column(db.Integer)
    ex_spouse = db.Column(db.Integer)
    data_year = db.Column(db.Integer)

NIBRSAgencyDenormVictimOffenderRelationship_index = Index('ori_index_nibrs_agency_denorm_victim_offender_relationship', NIBRSAgencyDenormVictimOffenderRelationship.ori)


class NIBRSStateDenormVictimOffenderRelationship(db.Model):
    """Represents Agency Level NIBRS Victim Data"""
    __tablename__ = 'nibrs_state_denorm_victim_offender_relationship'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )

    def get(state_abbr=None):
        query = NIBRSStateDenormVictimOffenderRelationship.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateDenormVictimOffenderRelationship.state_abbr) == func.lower(state_abbr))

        return query

    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    offense_name = db.Column(db.String)
    acquaintance = db.Column(db.Integer)
    babysittee = db.Column(db.Integer)
    boyfriend_girlfriend = db.Column(db.Integer)
    child_boyfriend_girlfriend = db.Column(db.Integer)
    child = db.Column(db.Integer)
    common_law_spouse = db.Column(db.Integer)
    employee = db.Column(db.Integer)
    employer = db.Column(db.Integer)
    friend = db.Column(db.Integer)
    grandchild = db.Column(db.Integer)
    grandparent = db.Column(db.Integer)
    homosexual_relationship = db.Column(db.Integer)
    in_law = db.Column(db.Integer)
    neighbor = db.Column(db.Integer)
    other_family_member = db.Column(db.Integer)
    otherwise_known = db.Column(db.Integer)
    parent = db.Column(db.Integer)
    relationship_unknown = db.Column(db.Integer)
    sibling = db.Column(db.Integer)
    stepchild = db.Column(db.Integer)
    spouse = db.Column(db.Integer)
    stepparent = db.Column(db.Integer)
    stepsibling = db.Column(db.Integer)
    stranger = db.Column(db.Integer)
    offender = db.Column(db.Integer)
    ex_spouse = db.Column(db.Integer)
    data_year = db.Column(db.Integer)


class NIBRSNationalOffenseCount(db.Model):
    """Represents Agency Level NIBRS Offender Ethnicity Data"""
    __tablename__ = 'nibrs_national_denorm_offense_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year'),
    )
    offense_name = db.Column(db.String)
    data_year = db.Column(db.Integer)
    incident_count = db.Column(db.Integer)
    offense_count = db.Column(db.Integer)

class NIBRSAgencyOffenseCount(db.Model):
    """Represents Agency Level NIBRS Offender Ethnicity Data"""
    __tablename__ = 'nibrs_agency_denorm_offense_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','ori'),
    )
    def get(ori=None):
        query = NIBRSAgencyOffenseCount.query

        if ori:
            query = query.filter(func.lower(NIBRSAgencyOffenseCount.ori) == func.lower(ori))

        return query

    offense_name = db.Column(db.String)
    ori = db.Column(db.String)
    agency_id = db.Column(db.Integer)
    data_year = db.Column(db.Integer)
    incident_count = db.Column(db.Integer)
    offense_count = db.Column(db.Integer)

NIBRSAgencyOffenseCount_index = Index('ori_index_nibrs_agency_denorm_offense_count', NIBRSAgencyOffenseCount.ori)


class NIBRSStateOffenseCount(db.Model):
    """Represents Agency Level NIBRS Offender Ethnicity Data"""
    __tablename__ = 'nibrs_state_denorm_offense_count'
    __table_args__ = (
        PrimaryKeyConstraint('offense_name', 'data_year','state_id'),
    )
    def get(state_abbr=None):
        query = NIBRSStateOffenseCount.query

        if state_abbr:
            query = query.filter(func.lower(NIBRSStateOffenseCount.state_abbr) == func.lower(state_abbr))

        return query
    offense_name = db.Column(db.String)
    state_abbr = db.Column(db.String)
    state_id = db.Column(db.Integer)
    data_year = db.Column(db.Integer)
    incident_count = db.Column(db.Integer)
    offense_count = db.Column(db.Integer)

class PoliceEmploymentDataNation(db.Model):
    __tablename__ = 'police_employment_nation'
    __table_args__ = (UniqueConstraint('data_year'), )

    data_year = db.Column(db.SmallInteger, primary_key=True)
    population = db.Column(db.Integer)
    male_officer_ct = db.Column(db.Integer)
    male_civilian_ct = db.Column(db.Integer)
    male_total_ct = db.Column(db.Integer)
    female_officer_ct = db.Column(db.Integer)
    female_civilian_ct = db.Column(db.Integer)
    female_total_ct = db.Column(db.Integer)
    officer_ct = db.Column(db.Integer)
    civilian_ct = db.Column(db.Integer)
    total_pe_ct = db.Column(db.Integer)
    pe_ct_per_1000 = db.Column(db.Float)

class PoliceEmploymentDataRegion(db.Model):
    __tablename__ = 'police_employment_region'
    __table_args__ = (UniqueConstraint('data_year'), )

    def get(region_name=None):
        """
        A method to find police employment data by region
        """
        query = PoliceEmploymentDataRegion.query

        if region_name:
            query = query.filter(func.lower(PoliceEmploymentDataRegion.region_name) == func.lower(region_name))

        return query

    data_year = db.Column(db.SmallInteger, primary_key=True)
    region_code	= db.Column(db.SmallInteger)
    region_name	= db.Column(db.String(100))
    population = db.Column(db.Integer)
    male_officer_ct = db.Column(db.Integer)
    male_civilian_ct = db.Column(db.Integer)
    male_total_ct = db.Column(db.Integer)
    female_officer_ct = db.Column(db.Integer)
    female_civilian_ct = db.Column(db.Integer)
    female_total_ct = db.Column(db.Integer)
    officer_ct = db.Column(db.Integer)
    civilian_ct = db.Column(db.Integer)
    total_pe_ct = db.Column(db.Integer)
    pe_ct_per_1000 = db.Column(db.Float)

class PoliceEmploymentDataState(db.Model):
    __tablename__ = 'police_employment_state'
    __table_args__ = (UniqueConstraint('data_year'), )

    def get(state_abbr=None):
        """
        A method to find police employment data by state
        """
        query = PoliceEmploymentDataState.query

        if state_abbr:
            query = query.filter(func.lower(PoliceEmploymentDataState.state_abbr) == func.lower(state_abbr))

        return query

    data_year = db.Column(db.SmallInteger, primary_key=True)
    state_id = db.Column(db.SmallInteger)
    state_name = db.Column(db.String(100))
    state_abbr = db.Column(db.String(2))
    population = db.Column(db.Integer)
    male_officer_ct = db.Column(db.Integer)
    male_civilian_ct = db.Column(db.Integer)
    male_total_ct = db.Column(db.Integer)
    female_officer_ct = db.Column(db.Integer)
    female_civilian_ct = db.Column(db.Integer)
    female_total_ct = db.Column(db.Integer)
    officer_ct = db.Column(db.Integer)
    civilian_ct = db.Column(db.Integer)
    total_pe_ct = db.Column(db.Integer)
    pe_ct_per_1000 = db.Column(db.Float)

class PoliceEmploymentDataAgency(db.Model):
    __tablename__ = 'police_employment_agency'
    __table_args__ = (UniqueConstraint('data_year','ori'), )

    def get(state_abbr=None, ori=None):
        """
        A method to find a police employment data by agency
        """
        query = PoliceEmploymentDataAgency.query

        if state_abbr and ori:
            query = query.filter(func.lower(PoliceEmploymentDataAgency.state_abbr) == func.lower(state_abbr))
            query = query.filter(func.lower(PoliceEmploymentDataAgency.ori) == func.lower(ori))

        return query

    ori = db.Column(db.String(25), primary_key=True)
    agency_type_name = db.Column(db.String(100))
    agency_name_edit  = db.Column(db.String(100))
    ncic_agency_name  = db.Column(db.String(100))
    data_year = db.Column(db.SmallInteger, primary_key=True)
    state_abbr  = db.Column(db.String(2))
    population = db.Column(db.Integer)
    male_officer_ct = db.Column(db.Integer)
    male_civilian_ct = db.Column(db.Integer)
    male_total_ct = db.Column(db.Integer)
    female_officer_ct = db.Column(db.Integer)
    female_civilian_ct = db.Column(db.Integer)
    female_total_ct = db.Column(db.Integer)
    officer_ct = db.Column(db.Integer)
    civilian_ct = db.Column(db.Integer)
    total_pe_ct = db.Column(db.Integer)
    pe_ct_per_1000 = db.Column(db.Float)

class LeokaAssaultByGroupNational(db.Model):
    """Represents National Level Leoka Assault Group Data"""
    __tablename__ = 'leoka_assault_by_group_national'
    __table_args__ = (
        PrimaryKeyConstraint('activity_name', 'data_year'),
    )
    data_year  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id  = db.Column(db.Integer)
    group_1_actual_ct = db.Column(db.Integer)
    group_2_actual_ct = db.Column(db.Integer)
    group_3_actual_ct = db.Column(db.Integer)
    group_4_actual_ct = db.Column(db.Integer)
    group_5_actual_ct = db.Column(db.Integer)
    group_6_actual_ct = db.Column(db.Integer)
    group_7_actual_ct = db.Column(db.Integer)
    group_8_actual_ct = db.Column(db.Integer)
    group_9_actual_ct = db.Column(db.Integer)
    group_1_cleared_ct = db.Column(db.Integer)
    group_2_cleared_ct = db.Column(db.Integer)
    group_3_cleared_ct = db.Column(db.Integer)
    group_4_cleared_ct = db.Column(db.Integer)
    group_5_cleared_ct = db.Column(db.Integer)
    group_6_cleared_ct = db.Column(db.Integer)
    group_7_cleared_ct = db.Column(db.Integer)
    group_8_cleared_ct = db.Column(db.Integer)
    group_9_cleared_ct = db.Column(db.Integer)


class LeokaAssaultByGroupRegional(db.Model):
    """Represents Regional Level Leoka Assault Group Data"""
    __tablename__ = 'leoka_assault_by_group_regional'
    __table_args__ = (
        PrimaryKeyConstraint('activity_name', 'data_year', 'region_code'),
    )
    def get(region_name=None):
        query = LeokaAssaultByGroupRegional.query

        if region_name:
            query = query.filter(func.lower(LeokaAssaultByGroupRegional.region_name) == func.lower(region_name))

        return query

    data_year  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id  = db.Column(db.Integer)
    region_name = db.Column(db.String)
    region_code  = db.Column(db.Integer)
    group_1_actual_ct = db.Column(db.Integer)
    group_2_actual_ct = db.Column(db.Integer)
    group_3_actual_ct = db.Column(db.Integer)
    group_4_actual_ct = db.Column(db.Integer)
    group_5_actual_ct = db.Column(db.Integer)
    group_6_actual_ct = db.Column(db.Integer)
    group_7_actual_ct = db.Column(db.Integer)
    group_8_actual_ct = db.Column(db.Integer)
    group_9_actual_ct = db.Column(db.Integer)
    group_1_cleared_ct = db.Column(db.Integer)
    group_2_cleared_ct = db.Column(db.Integer)
    group_3_cleared_ct = db.Column(db.Integer)
    group_4_cleared_ct = db.Column(db.Integer)
    group_5_cleared_ct = db.Column(db.Integer)
    group_6_cleared_ct = db.Column(db.Integer)
    group_7_cleared_ct = db.Column(db.Integer)
    group_8_cleared_ct = db.Column(db.Integer)
    group_9_cleared_ct = db.Column(db.Integer)

class LeokaAssaultByGroupState(db.Model):
    """Represents Regional Level Leoka Assault Group Data"""
    __tablename__ = 'leoka_assault_by_group_state'
    __table_args__ = (
        PrimaryKeyConstraint('activity_name', 'data_year', 'state_abbr'),
    )
    def get(state_abbr=None):
        query = LeokaAssaultByGroupState.query

        if state_abbr:
            query = query.filter(func.lower(leoka_assault_by_group_state.state_abbr) == func.lower(state_abbr))

        return query

    data_year  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id  = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    state_id  = db.Column(db.Integer)
    group_1_actual_ct = db.Column(db.Integer)
    group_2_actual_ct = db.Column(db.Integer)
    group_3_actual_ct = db.Column(db.Integer)
    group_4_actual_ct = db.Column(db.Integer)
    group_5_actual_ct = db.Column(db.Integer)
    group_6_actual_ct = db.Column(db.Integer)
    group_7_actual_ct = db.Column(db.Integer)
    group_8_actual_ct = db.Column(db.Integer)
    group_9_actual_ct = db.Column(db.Integer)
    group_1_cleared_ct = db.Column(db.Integer)
    group_2_cleared_ct = db.Column(db.Integer)
    group_3_cleared_ct = db.Column(db.Integer)
    group_4_cleared_ct = db.Column(db.Integer)
    group_5_cleared_ct = db.Column(db.Integer)
    group_6_cleared_ct = db.Column(db.Integer)
    group_7_cleared_ct = db.Column(db.Integer)
    group_8_cleared_ct = db.Column(db.Integer)
    group_9_cleared_ct = db.Column(db.Integer)

class LeokaAssaultAssignDistNational(db.Model):
    """
    A method to find Leoka Assault Assignment Distrubution
    """
    __tablename__ = 'leoka_assault_by_assign_dist_national'
    __table_args__ = (
        PrimaryKeyConstraint('activity_name', 'data_year'),
    )
    data_year  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id  = db.Column(db.Integer)
    two_officers_vehicle_actual = db.Column(db.Integer)
    one_officer_vehicle_actual = db.Column(db.Integer)
    one_officer_assisted_actual = db.Column(db.Integer)
    det_spe_ass_alone_actual = db.Column(db.Integer)
    det_spe_ass_assisted_actual = db.Column(db.Integer)
    other_alone_actual = db.Column(db.Integer)
    other_assisted_actual = db.Column(db.Integer)


class LeokaAssaultAssignDistRegional(db.Model):
    """
    Represents Regional Level Leoka Assault Assignment Distrubution
    """
    __tablename__ = 'leoka_assault_by_assign_dist_regional'
    __table_args__ = (
        PrimaryKeyConstraint('activity_name', 'data_year', 'region_name'),
    )
    def get(region_name=None):
        query = LeokaAssaultAssignDistRegional.query

        if region_name:
            query = query.filter(func.lower(LeokaAssaultAssignDistRegional.region_name) == func.lower(region_name))

        return query

    data_year  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id  = db.Column(db.Integer)
    region_name = db.Column(db.String)
    region_code  = db.Column(db.Integer)
    two_officers_vehicle_actual = db.Column(db.Integer)
    one_officer_vehicle_actual = db.Column(db.Integer)
    one_officer_assisted_actual = db.Column(db.Integer)
    det_spe_ass_alone_actual = db.Column(db.Integer)
    det_spe_ass_assisted_actual = db.Column(db.Integer)
    other_alone_actual = db.Column(db.Integer)
    other_assisted_actual = db.Column(db.Integer)


class LeokaAssaultAssignDistState(db.Model):
    """Represents State Level LLeoka Assault Assignment Distrubution"""
    __tablename__ = 'leoka_assault_by_assign_dist_state'
    __table_args__ = (
        PrimaryKeyConstraint('activity_name', 'data_year', 'state_abbr'),
    )
    def get(state_abbr=None):
        query = LeokaAssaultAssignDistState.query

        if state_abbr:
            query = query.filter(func.lower(LeokaAssaultAssignDistState.state_abbr) == func.lower(state_abbr))

        return query

    data_year  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id  = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    state_id  = db.Column(db.Integer)
    two_officers_vehicle_actual = db.Column(db.Integer)
    one_officer_vehicle_actual = db.Column(db.Integer)
    one_officer_assisted_actual = db.Column(db.Integer)
    det_spe_ass_alone_actual = db.Column(db.Integer)
    det_spe_ass_assisted_actual = db.Column(db.Integer)
    other_alone_actual = db.Column(db.Integer)
    other_assisted_actual = db.Column(db.Integer)

class LeokaAssaultAssignDistAgency(db.Model):
    """Represents Agency Level Leoka Assault Assignment Distrubution"""
    __tablename__ = 'leoka_assault_by_assign_dist_agency'
    __table_args__ = (
        PrimaryKeyConstraint('activity_name', 'data_year', 'ori'),
    )
    def get(ori=None):
        query = LeokaAssaultAssignDistAgency.query

        if ori:
            query = query.filter(func.lower(LeokaAssaultAssignDistAgency.ori) == func.lower(ori))

        return query

    data_year  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id  = db.Column(db.Integer)
    ori = db.Column(db.String)
    state_abbr  = db.Column(db.String)
    two_officers_vehicle_actual = db.Column(db.Integer)
    one_officer_vehicle_actual = db.Column(db.Integer)
    one_officer_assisted_actual = db.Column(db.Integer)
    det_spe_ass_alone_actual = db.Column(db.Integer)
    det_spe_ass_assisted_actual = db.Column(db.Integer)
    other_alone_actual = db.Column(db.Integer)
    other_assisted_actual = db.Column(db.Integer)

class LeokaAssaultWeaponNational(db.Model):
    """
    Repreents National level find Leoka Assault Weapon Totals
    """
    __tablename__ = 'leoka_assault_by_weapon_national'
    __table_args__ = (
        PrimaryKeyConstraint('data_year'),
    )
    data_year  = db.Column(db.Integer)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)

class LeokaAssaultWeaponRegional(db.Model):
    """
    Represents Regional Level Leoka Weapon Totals
    """
    __tablename__ = 'leoka_assault_by_weapon_regional'
    __table_args__ = (
        PrimaryKeyConstraint('data_year', 'region_code'),
    )
    def get(region_code=None):
        query = LeokaAssaultByGroupRegional.query

        if region_name:
            query = query.filter(func.lower(LeokaAssaultByGroupRegional.region_code) == func.lower(region_code))

        return query

    data_year  = db.Column(db.Integer)
    region_name = db.Column(db.String)
    region_code  = db.Column(db.Integer)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)

class LeokaAssaultWeaponState(db.Model):
    """Represents State Level LLeoka Assault Assignment Distrubution"""
    __tablename__ = 'leoka_assault_by_weapon_state'
    __table_args__ = (
        PrimaryKeyConstraint('data_year', 'state_abbr'),
    )
    def get(state_abbr=None):
        query = LeokaAssaultWeaponState.query

        if state_abbr:
            query = query.filter(func.lower(LeokaAssaultWeaponState.state_abbr) == func.lower(state_abbr))

        return query

    data_year  = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    state_id  = db.Column(db.Integer)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)

class LeokaAssaultWeaponAgency(db.Model):
    """Represents Agency Level Leoka Assault Assignment Distrubution"""
    __tablename__ = 'leoka_assault_by_weapon_agency'
    __table_args__ = (
        PrimaryKeyConstraint('data_year', 'ori'),
    )
    def get(ori=None):
        query = LeokaAssaultWeaponAgency.query

        if ori:
            query = query.filter(func.lower(LeokaAssaultWeaponAgency.ori) == func.lower(ori))

        return query

    data_year  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id  = db.Column(db.Integer)
    ori = db.Column(db.String)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)

class LeokaAssaultWeaponByGroupNational(db.Model):
    """
    Repreents National level find Leoka Assault Weapon Totals by Group
    """
    __tablename__ = 'leoka_assault_by_weapon_per_group_national'
    __table_args__ = (
        PrimaryKeyConstraint('population_group_desc', 'data_year'),
    )
    data_year  = db.Column(db.Integer)
    population_group_desc = db.Column(db.String)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)

class LeokaAssaultWeaponByGroupRegional(db.Model):
    """
    Represents Regional Level Leoka Weapon Totals  By Group
    """
    __tablename__ = 'leoka_assault_by_weapon_per_group_regional'
    __table_args__ = (
        PrimaryKeyConstraint('data_year', 'region_name','population_group_desc'),
    )
    def get(region_name=None):
        query = LeokaAssaultWeaponByGroupRegional.query

        if region_name:
            query = query.filter(func.lower(LeokaAssaultWeaponByGroupRegional.region_name) == func.lower(region_name))

        return query

    data_year  = db.Column(db.Integer)
    region_name = db.Column(db.String)
    region_code  = db.Column(db.Integer)
    population_group_desc = db.Column(db.String)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)

class LeokaAssaultWeaponByGroupState(db.Model):
    """
    Represents State Level Leoka Weapon Totals By Group
    """
    __tablename__ = 'leoka_assault_by_weapon_per_group_state'
    __table_args__ = (
        PrimaryKeyConstraint('data_year', 'state_abbr','population_group_desc'),
    )
    def get(state_abbr=None):
        query = LeokaAssaultWeaponByGroupState.query

        if state_abbr:
            query = query.filter(func.lower(LeokaAssaultWeaponByGroupState.state_abbr) == func.lower(state_abbr))

        return query

    data_year  = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    state_id  = db.Column(db.Integer)
    population_group_desc = db.Column(db.String)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)


class LeokaAssaultWeaponByActivityNational(db.Model):
    """
    Repreents National level find Leoka Assault Weapon Totals by Activity
    """
    __tablename__ = 'leoka_assault_by_weapon_per_activity_national'
    __table_args__ = (
        PrimaryKeyConstraint('activity_id', 'data_year'),
    )
    data_year  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id = db.Column(db.Integer)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)

class LeokaAssaultWeaponByActivityRegional(db.Model):
    """
    Represents Regional Level Leoka Weapon Totals  By Activity
    """
    __tablename__ = 'leoka_assault_by_weapon_per_activity_regional'
    __table_args__ = (
        PrimaryKeyConstraint('data_year', 'region_name','activity_id'),
    )
    def get(region_name=None):
        query = LeokaAssaultWeaponByActivityRegional.query

        if region_name:
            query = query.filter(func.lower(LeokaAssaultWeaponByActivityRegional.region_name) == func.lower(region_name))

        return query

    data_year  = db.Column(db.Integer)
    region_name = db.Column(db.String)
    region_code  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id = db.Column(db.Integer)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)

class LeokaAssaultWeaponByActivityState(db.Model):
    """
    Represents Regional Level Leoka Weapon Totals  By Activity
    """
    __tablename__ = 'leoka_assault_by_weapon_per_activity_state'
    __table_args__ = (
        PrimaryKeyConstraint('data_year', 'state_abbr','activity_id'),
    )
    def get(state_abbr=None):
        query = LeokaAssaultWeaponByActivityState.query

        if state_abbr:
            query = query.filter(func.lower(LeokaAssaultWeaponByActivityState.state_abbr) == func.lower(state_abbr))

        return query

    data_year  = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    state_id  = db.Column(db.Integer)
    activity_name = db.Column(db.String)
    activity_id = db.Column(db.Integer)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)

class LeokaAssaultWeaponByActivityAgency(db.Model):
    """
    Represents Regional Level Leoka Weapon Totals By Activity
    """
    __tablename__ = 'leoka_assault_by_weapon_per_activity_agency'
    __table_args__ = (
        PrimaryKeyConstraint('data_year', 'ori','activity_id'),
    )
    def get(state_abbr=None):
        query = LeokaAssaultWeaponByActivityAgency.query

        if ori:
            query = query.filter(func.lower(LeokaAssaultWeaponByActivityAgency.ori) == func.lower(ori))

        return query

    data_year  = db.Column(db.Integer)
    ori = db.Column(db.String)
    state_abbr  = db.Column(db.String)
    activity_name = db.Column(db.String)
    activity_id = db.Column(db.Integer)
    firearm_actual = db.Column(db.Integer)
    knife_actual = db.Column(db.Integer)
    hands_fists_feet_actual = db.Column(db.Integer)
    other_actual = db.Column(db.Integer)
