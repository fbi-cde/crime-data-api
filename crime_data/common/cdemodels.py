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

class ASRMaleByAgeCountAgency(db.Model):
    """Represents Agency Level ASR data for males by age"""
    __tablename__ = 'asr_age_male_count_agency'
    __table_args__ = (
        PrimaryKeyConstraint('age_group', 'data_year','agency_id'),
    )

    def get(ori=None):
        query = ASRMaleByAgeCountAgency.query

        if ori:
            query = query.filter(func.lower(ASRMaleByAgeCountAgency.ori) == func.lower(ori))

        return query

    data_year = db.Column(db.Integer)
    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    age_group = db.Column(db.String)
    aggravated_assault = db.Column(db.Integer)
    all_other_offenses_except_traffic = db.Column(db.Integer)
    arson = db.Column(db.Integer)
    burglary_breaking_or_entering = db.Column(db.Integer)
    curfew_and_loitering_law_violations = db.Column(db.Integer)
    disorderly_conduct = db.Column(db.Integer)
    driving_under_the_influence = db.Column(db.Integer)
    drug_abuse_violations_grand_total = db.Column(db.Integer)
    drug_possession_marijuana = db.Column(db.Integer)
    drug_possession_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_possession_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_possession_subtotal = db.Column(db.Integer)
    drug_possession_synthetic_narcotics = db.Column(db.Integer)
    drug_sale_manufacturing_marijuana = db.Column(db.Integer)
    drug_sale_manufacturing_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_sale_manufacturing_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_sale_manufacturing_subtotal = db.Column(db.Integer)
    drug_sale_manufacturing_synthetic_narcotics = db.Column(db.Integer)
    drunkenness = db.Column(db.Integer)
    embezzlement = db.Column(db.Integer)
    forgery_and_counterfeiting = db.Column(db.Integer)
    fraud = db.Column(db.Integer)
    gambling_all_other_gambling = db.Column(db.Integer)
    gambling_bookmaking_horse_and_sport_book = db.Column(db.Integer)
    gambling_numbers_and_lottery = db.Column(db.Integer)
    gambling_total = db.Column(db.Integer)
    human_trafficking_commercial_sex_acts = db.Column(db.Integer)
    human_trafficking_involuntary_servitude = db.Column(db.Integer)
    juvenile_disposition = db.Column(db.Integer)
    larceny_theft = db.Column(db.Integer)
    liquor_laws = db.Column(db.Integer)
    manslaughter_by_negligence = db.Column(db.Integer)
    motor_vehicle_theft = db.Column(db.Integer)
    murder_and_nonnegligent_manslaughter = db.Column(db.Integer)
    offenses_against_the_family_and_children = db.Column(db.Integer)
    prostitution_and_commercialized_vice = db.Column(db.Integer)
    prostitution_and_commercialized_vice_assisting_or_promoting_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_purchasing_prostitution = db.Column(db.Integer)
    rape = db.Column(db.Integer)
    robbery = db.Column(db.Integer)
    runaway = db.Column(db.Integer)
    sex_offenses_except_rape_and_prostitution_and_commercialized_vice = db.Column(db.Integer)
    simple_assault = db.Column(db.Integer)
    stolen_property_buying_receiving_possessing = db.Column(db.Integer)
    suspicion = db.Column(db.Integer)
    vagrancy = db.Column(db.Integer)
    vandalism = db.Column(db.Integer)
    weapons_carrying_possessing_etc = db.Column(db.Integer)
    zero_report = db.Column(db.Integer)

class ASRMaleByAgeCountState(db.Model):
    """Represents State Level ASR data for males by age"""
    __tablename__ = 'asr_age_male_count_state'
    __table_args__ = (
        PrimaryKeyConstraint('age_group', 'data_year','state_abbr'),
    )

    def get(state_abbr=None):
        query = ASRMaleByAgeCountState.query

        if state_abbr:
            query = query.filter(func.lower(ASRMaleByAgeCountState.state_abbr) == func.lower(state_abbr))

        return query

    data_year = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    age_group = db.Column(db.String)
    aggravated_assault = db.Column(db.Integer)
    all_other_offenses_except_traffic = db.Column(db.Integer)
    arson = db.Column(db.Integer)
    burglary_breaking_or_entering = db.Column(db.Integer)
    curfew_and_loitering_law_violations = db.Column(db.Integer)
    disorderly_conduct = db.Column(db.Integer)
    driving_under_the_influence = db.Column(db.Integer)
    drug_abuse_violations_grand_total = db.Column(db.Integer)
    drug_possession_marijuana = db.Column(db.Integer)
    drug_possession_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_possession_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_possession_subtotal = db.Column(db.Integer)
    drug_possession_synthetic_narcotics = db.Column(db.Integer)
    drug_sale_manufacturing_marijuana = db.Column(db.Integer)
    drug_sale_manufacturing_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_sale_manufacturing_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_sale_manufacturing_subtotal = db.Column(db.Integer)
    drug_sale_manufacturing_synthetic_narcotics = db.Column(db.Integer)
    drunkenness = db.Column(db.Integer)
    embezzlement = db.Column(db.Integer)
    forgery_and_counterfeiting = db.Column(db.Integer)
    fraud = db.Column(db.Integer)
    gambling_all_other_gambling = db.Column(db.Integer)
    gambling_bookmaking_horse_and_sport_book = db.Column(db.Integer)
    gambling_numbers_and_lottery = db.Column(db.Integer)
    gambling_total = db.Column(db.Integer)
    human_trafficking_commercial_sex_acts = db.Column(db.Integer)
    human_trafficking_involuntary_servitude = db.Column(db.Integer)
    juvenile_disposition = db.Column(db.Integer)
    larceny_theft = db.Column(db.Integer)
    liquor_laws = db.Column(db.Integer)
    manslaughter_by_negligence = db.Column(db.Integer)
    motor_vehicle_theft = db.Column(db.Integer)
    murder_and_nonnegligent_manslaughter = db.Column(db.Integer)
    offenses_against_the_family_and_children = db.Column(db.Integer)
    prostitution_and_commercialized_vice = db.Column(db.Integer)
    prostitution_and_commercialized_vice_assisting_or_promoting_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_purchasing_prostitution = db.Column(db.Integer)
    rape = db.Column(db.Integer)
    robbery = db.Column(db.Integer)
    runaway = db.Column(db.Integer)
    sex_offenses_except_rape_and_prostitution_and_commercialized_vice = db.Column(db.Integer)
    simple_assault = db.Column(db.Integer)
    stolen_property_buying_receiving_possessing = db.Column(db.Integer)
    suspicion = db.Column(db.Integer)
    vagrancy = db.Column(db.Integer)
    vandalism = db.Column(db.Integer)
    weapons_carrying_possessing_etc = db.Column(db.Integer)
    zero_report = db.Column(db.Integer)

class ASRMaleByAgeCountRegion(db.Model):
    """Represents Region Level ASR data for males by age"""
    __tablename__ = 'asr_age_male_count_region'
    __table_args__ = (
        PrimaryKeyConstraint('age_group', 'data_year','region_name'),
    )

    def get(region_name=None):
        query = ASRMaleByAgeCountRegion.query

        if region_name:
            query = query.filter(func.lower(ASRMaleByAgeCountRegion.region_name) == func.lower(region_name))

        return query

    data_year = db.Column(db.Integer)
    region_name = db.Column(db.String)
    age_group = db.Column(db.String)
    aggravated_assault = db.Column(db.Integer)
    all_other_offenses_except_traffic = db.Column(db.Integer)
    arson = db.Column(db.Integer)
    burglary_breaking_or_entering = db.Column(db.Integer)
    curfew_and_loitering_law_violations = db.Column(db.Integer)
    disorderly_conduct = db.Column(db.Integer)
    driving_under_the_influence = db.Column(db.Integer)
    drug_abuse_violations_grand_total = db.Column(db.Integer)
    drug_possession_marijuana = db.Column(db.Integer)
    drug_possession_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_possession_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_possession_subtotal = db.Column(db.Integer)
    drug_possession_synthetic_narcotics = db.Column(db.Integer)
    drug_sale_manufacturing_marijuana = db.Column(db.Integer)
    drug_sale_manufacturing_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_sale_manufacturing_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_sale_manufacturing_subtotal = db.Column(db.Integer)
    drug_sale_manufacturing_synthetic_narcotics = db.Column(db.Integer)
    drunkenness = db.Column(db.Integer)
    embezzlement = db.Column(db.Integer)
    forgery_and_counterfeiting = db.Column(db.Integer)
    fraud = db.Column(db.Integer)
    gambling_all_other_gambling = db.Column(db.Integer)
    gambling_bookmaking_horse_and_sport_book = db.Column(db.Integer)
    gambling_numbers_and_lottery = db.Column(db.Integer)
    gambling_total = db.Column(db.Integer)
    human_trafficking_commercial_sex_acts = db.Column(db.Integer)
    human_trafficking_involuntary_servitude = db.Column(db.Integer)
    juvenile_disposition = db.Column(db.Integer)
    larceny_theft = db.Column(db.Integer)
    liquor_laws = db.Column(db.Integer)
    manslaughter_by_negligence = db.Column(db.Integer)
    motor_vehicle_theft = db.Column(db.Integer)
    murder_and_nonnegligent_manslaughter = db.Column(db.Integer)
    offenses_against_the_family_and_children = db.Column(db.Integer)
    prostitution_and_commercialized_vice = db.Column(db.Integer)
    prostitution_and_commercialized_vice_assisting_or_promoting_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_purchasing_prostitution = db.Column(db.Integer)
    rape = db.Column(db.Integer)
    robbery = db.Column(db.Integer)
    runaway = db.Column(db.Integer)
    sex_offenses_except_rape_and_prostitution_and_commercialized_vice = db.Column(db.Integer)
    simple_assault = db.Column(db.Integer)
    stolen_property_buying_receiving_possessing = db.Column(db.Integer)
    suspicion = db.Column(db.Integer)
    vagrancy = db.Column(db.Integer)
    vandalism = db.Column(db.Integer)
    weapons_carrying_possessing_etc = db.Column(db.Integer)
    zero_report = db.Column(db.Integer)

class ASRMaleByAgeCountNational(db.Model):
    """Represents National Level ASR data for males by age"""
    __tablename__ = 'asr_age_male_count_national'
    __table_args__ = (
        PrimaryKeyConstraint('age_group', 'data_year'),
    )

    data_year = db.Column(db.Integer)
    age_group = db.Column(db.String)
    aggravated_assault = db.Column(db.Integer)
    all_other_offenses_except_traffic = db.Column(db.Integer)
    arson = db.Column(db.Integer)
    burglary_breaking_or_entering = db.Column(db.Integer)
    curfew_and_loitering_law_violations = db.Column(db.Integer)
    disorderly_conduct = db.Column(db.Integer)
    driving_under_the_influence = db.Column(db.Integer)
    drug_abuse_violations_grand_total = db.Column(db.Integer)
    drug_possession_marijuana = db.Column(db.Integer)
    drug_possession_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_possession_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_possession_subtotal = db.Column(db.Integer)
    drug_possession_synthetic_narcotics = db.Column(db.Integer)
    drug_sale_manufacturing_marijuana = db.Column(db.Integer)
    drug_sale_manufacturing_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_sale_manufacturing_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_sale_manufacturing_subtotal = db.Column(db.Integer)
    drug_sale_manufacturing_synthetic_narcotics = db.Column(db.Integer)
    drunkenness = db.Column(db.Integer)
    embezzlement = db.Column(db.Integer)
    forgery_and_counterfeiting = db.Column(db.Integer)
    fraud = db.Column(db.Integer)
    gambling_all_other_gambling = db.Column(db.Integer)
    gambling_bookmaking_horse_and_sport_book = db.Column(db.Integer)
    gambling_numbers_and_lottery = db.Column(db.Integer)
    gambling_total = db.Column(db.Integer)
    human_trafficking_commercial_sex_acts = db.Column(db.Integer)
    human_trafficking_involuntary_servitude = db.Column(db.Integer)
    juvenile_disposition = db.Column(db.Integer)
    larceny_theft = db.Column(db.Integer)
    liquor_laws = db.Column(db.Integer)
    manslaughter_by_negligence = db.Column(db.Integer)
    motor_vehicle_theft = db.Column(db.Integer)
    murder_and_nonnegligent_manslaughter = db.Column(db.Integer)
    offenses_against_the_family_and_children = db.Column(db.Integer)
    prostitution_and_commercialized_vice = db.Column(db.Integer)
    prostitution_and_commercialized_vice_assisting_or_promoting_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_purchasing_prostitution = db.Column(db.Integer)
    rape = db.Column(db.Integer)
    robbery = db.Column(db.Integer)
    runaway = db.Column(db.Integer)
    sex_offenses_except_rape_and_prostitution_and_commercialized_vice = db.Column(db.Integer)
    simple_assault = db.Column(db.Integer)
    stolen_property_buying_receiving_possessing = db.Column(db.Integer)
    suspicion = db.Column(db.Integer)
    vagrancy = db.Column(db.Integer)
    vandalism = db.Column(db.Integer)
    weapons_carrying_possessing_etc = db.Column(db.Integer)
    zero_report = db.Column(db.Integer)

class ASRFemaleByAgeCountAgency(db.Model):
    """Represents Agency Level ASR data for Females by age"""
    __tablename__ = 'asr_age_female_count_agency'
    __table_args__ = (
        PrimaryKeyConstraint('age_group', 'data_year','agency_id'),
    )

    def get(ori=None):
        query = ASRFemaleByAgeCountAgency.query

        if ori:
            query = query.filter(func.lower(ASRFemaleByAgeCountAgency.ori) == func.lower(ori))

        return query

    data_year = db.Column(db.Integer)
    agency_id = db.Column(db.Integer)
    ori = db.Column(db.String)
    age_group = db.Column(db.String)
    aggravated_assault = db.Column(db.Integer)
    all_other_offenses_except_traffic = db.Column(db.Integer)
    arson = db.Column(db.Integer)
    burglary_breaking_or_entering = db.Column(db.Integer)
    curfew_and_loitering_law_violations = db.Column(db.Integer)
    disorderly_conduct = db.Column(db.Integer)
    driving_under_the_influence = db.Column(db.Integer)
    drug_abuse_violations_grand_total = db.Column(db.Integer)
    drug_possession_marijuana = db.Column(db.Integer)
    drug_possession_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_possession_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_possession_subtotal = db.Column(db.Integer)
    drug_possession_synthetic_narcotics = db.Column(db.Integer)
    drug_sale_manufacturing_marijuana = db.Column(db.Integer)
    drug_sale_manufacturing_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_sale_manufacturing_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_sale_manufacturing_subtotal = db.Column(db.Integer)
    drug_sale_manufacturing_synthetic_narcotics = db.Column(db.Integer)
    drunkenness = db.Column(db.Integer)
    embezzlement = db.Column(db.Integer)
    forgery_and_counterfeiting = db.Column(db.Integer)
    fraud = db.Column(db.Integer)
    gambling_all_other_gambling = db.Column(db.Integer)
    gambling_bookmaking_horse_and_sport_book = db.Column(db.Integer)
    gambling_numbers_and_lottery = db.Column(db.Integer)
    gambling_total = db.Column(db.Integer)
    human_trafficking_commercial_sex_acts = db.Column(db.Integer)
    human_trafficking_involuntary_servitude = db.Column(db.Integer)
    juvenile_disposition = db.Column(db.Integer)
    larceny_theft = db.Column(db.Integer)
    liquor_laws = db.Column(db.Integer)
    manslaughter_by_negligence = db.Column(db.Integer)
    motor_vehicle_theft = db.Column(db.Integer)
    murder_and_nonnegligent_manslaughter = db.Column(db.Integer)
    offenses_against_the_family_and_children = db.Column(db.Integer)
    prostitution_and_commercialized_vice = db.Column(db.Integer)
    prostitution_and_commercialized_vice_assisting_or_promoting_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_purchasing_prostitution = db.Column(db.Integer)
    rape = db.Column(db.Integer)
    robbery = db.Column(db.Integer)
    runaway = db.Column(db.Integer)
    sex_offenses_except_rape_and_prostitution_and_commercialized_vice = db.Column(db.Integer)
    simple_assault = db.Column(db.Integer)
    stolen_property_buying_receiving_possessing = db.Column(db.Integer)
    suspicion = db.Column(db.Integer)
    vagrancy = db.Column(db.Integer)
    vandalism = db.Column(db.Integer)
    weapons_carrying_possessing_etc = db.Column(db.Integer)
    zero_report = db.Column(db.Integer)

class ASRFemaleByAgeCountState(db.Model):
    """Represents State Level ASR data for Females by age"""
    __tablename__ = 'asr_age_female_count_state'
    __table_args__ = (
        PrimaryKeyConstraint('age_group', 'data_year','state_abbr'),
    )

    def get(state_abbr=None):
        query = ASRFemaleByAgeCountState.query

        if state_abbr:
            query = query.filter(func.lower(ASRFemaleByAgeCountState.state_abbr) == func.lower(state_abbr))

        return query

    data_year = db.Column(db.Integer)
    state_abbr = db.Column(db.String)
    age_group = db.Column(db.String)
    aggravated_assault = db.Column(db.Integer)
    all_other_offenses_except_traffic = db.Column(db.Integer)
    arson = db.Column(db.Integer)
    burglary_breaking_or_entering = db.Column(db.Integer)
    curfew_and_loitering_law_violations = db.Column(db.Integer)
    disorderly_conduct = db.Column(db.Integer)
    driving_under_the_influence = db.Column(db.Integer)
    drug_abuse_violations_grand_total = db.Column(db.Integer)
    drug_possession_marijuana = db.Column(db.Integer)
    drug_possession_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_possession_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_possession_subtotal = db.Column(db.Integer)
    drug_possession_synthetic_narcotics = db.Column(db.Integer)
    drug_sale_manufacturing_marijuana = db.Column(db.Integer)
    drug_sale_manufacturing_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_sale_manufacturing_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_sale_manufacturing_subtotal = db.Column(db.Integer)
    drug_sale_manufacturing_synthetic_narcotics = db.Column(db.Integer)
    drunkenness = db.Column(db.Integer)
    embezzlement = db.Column(db.Integer)
    forgery_and_counterfeiting = db.Column(db.Integer)
    fraud = db.Column(db.Integer)
    gambling_all_other_gambling = db.Column(db.Integer)
    gambling_bookmaking_horse_and_sport_book = db.Column(db.Integer)
    gambling_numbers_and_lottery = db.Column(db.Integer)
    gambling_total = db.Column(db.Integer)
    human_trafficking_commercial_sex_acts = db.Column(db.Integer)
    human_trafficking_involuntary_servitude = db.Column(db.Integer)
    juvenile_disposition = db.Column(db.Integer)
    larceny_theft = db.Column(db.Integer)
    liquor_laws = db.Column(db.Integer)
    manslaughter_by_negligence = db.Column(db.Integer)
    motor_vehicle_theft = db.Column(db.Integer)
    murder_and_nonnegligent_manslaughter = db.Column(db.Integer)
    offenses_against_the_family_and_children = db.Column(db.Integer)
    prostitution_and_commercialized_vice = db.Column(db.Integer)
    prostitution_and_commercialized_vice_assisting_or_promoting_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_purchasing_prostitution = db.Column(db.Integer)
    rape = db.Column(db.Integer)
    robbery = db.Column(db.Integer)
    runaway = db.Column(db.Integer)
    sex_offenses_except_rape_and_prostitution_and_commercialized_vice = db.Column(db.Integer)
    simple_assault = db.Column(db.Integer)
    stolen_property_buying_receiving_possessing = db.Column(db.Integer)
    suspicion = db.Column(db.Integer)
    vagrancy = db.Column(db.Integer)
    vandalism = db.Column(db.Integer)
    weapons_carrying_possessing_etc = db.Column(db.Integer)
    zero_report = db.Column(db.Integer)

class ASRFemaleByAgeCountRegion(db.Model):
    """Represents Region Level ASR data for Females by age"""
    __tablename__ = 'asr_age_female_count_region'
    __table_args__ = (
        PrimaryKeyConstraint('age_group', 'data_year','region_name'),
    )

    def get(region_name=None):
        query = ASRFemaleByAgeCountRegion.query

        if region_name:
            query = query.filter(func.lower(ASRFemaleByAgeCountRegion.region_name) == func.lower(region_name))

        return query

    data_year = db.Column(db.Integer)
    region_name = db.Column(db.String)
    age_group = db.Column(db.String)
    aggravated_assault = db.Column(db.Integer)
    all_other_offenses_except_traffic = db.Column(db.Integer)
    arson = db.Column(db.Integer)
    burglary_breaking_or_entering = db.Column(db.Integer)
    curfew_and_loitering_law_violations = db.Column(db.Integer)
    disorderly_conduct = db.Column(db.Integer)
    driving_under_the_influence = db.Column(db.Integer)
    drug_abuse_violations_grand_total = db.Column(db.Integer)
    drug_possession_marijuana = db.Column(db.Integer)
    drug_possession_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_possession_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_possession_subtotal = db.Column(db.Integer)
    drug_possession_synthetic_narcotics = db.Column(db.Integer)
    drug_sale_manufacturing_marijuana = db.Column(db.Integer)
    drug_sale_manufacturing_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_sale_manufacturing_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_sale_manufacturing_subtotal = db.Column(db.Integer)
    drug_sale_manufacturing_synthetic_narcotics = db.Column(db.Integer)
    drunkenness = db.Column(db.Integer)
    embezzlement = db.Column(db.Integer)
    forgery_and_counterfeiting = db.Column(db.Integer)
    fraud = db.Column(db.Integer)
    gambling_all_other_gambling = db.Column(db.Integer)
    gambling_bookmaking_horse_and_sport_book = db.Column(db.Integer)
    gambling_numbers_and_lottery = db.Column(db.Integer)
    gambling_total = db.Column(db.Integer)
    human_trafficking_commercial_sex_acts = db.Column(db.Integer)
    human_trafficking_involuntary_servitude = db.Column(db.Integer)
    juvenile_disposition = db.Column(db.Integer)
    larceny_theft = db.Column(db.Integer)
    liquor_laws = db.Column(db.Integer)
    manslaughter_by_negligence = db.Column(db.Integer)
    motor_vehicle_theft = db.Column(db.Integer)
    murder_and_nonnegligent_manslaughter = db.Column(db.Integer)
    offenses_against_the_family_and_children = db.Column(db.Integer)
    prostitution_and_commercialized_vice = db.Column(db.Integer)
    prostitution_and_commercialized_vice_assisting_or_promoting_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_purchasing_prostitution = db.Column(db.Integer)
    rape = db.Column(db.Integer)
    robbery = db.Column(db.Integer)
    runaway = db.Column(db.Integer)
    sex_offenses_except_rape_and_prostitution_and_commercialized_vice = db.Column(db.Integer)
    simple_assault = db.Column(db.Integer)
    stolen_property_buying_receiving_possessing = db.Column(db.Integer)
    suspicion = db.Column(db.Integer)
    vagrancy = db.Column(db.Integer)
    vandalism = db.Column(db.Integer)
    weapons_carrying_possessing_etc = db.Column(db.Integer)
    zero_report = db.Column(db.Integer)

class ASRFemaleByAgeCountNational(db.Model):
    """Represents National Level ASR data for Females by age"""
    __tablename__ = 'asr_age_female_count_national'
    __table_args__ = (
        PrimaryKeyConstraint('age_group', 'data_year'),
    )

    data_year = db.Column(db.Integer)
    age_group = db.Column(db.String)
    aggravated_assault = db.Column(db.Integer)
    all_other_offenses_except_traffic = db.Column(db.Integer)
    arson = db.Column(db.Integer)
    burglary_breaking_or_entering = db.Column(db.Integer)
    curfew_and_loitering_law_violations = db.Column(db.Integer)
    disorderly_conduct = db.Column(db.Integer)
    driving_under_the_influence = db.Column(db.Integer)
    drug_abuse_violations_grand_total = db.Column(db.Integer)
    drug_possession_marijuana = db.Column(db.Integer)
    drug_possession_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_possession_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_possession_subtotal = db.Column(db.Integer)
    drug_possession_synthetic_narcotics = db.Column(db.Integer)
    drug_sale_manufacturing_marijuana = db.Column(db.Integer)
    drug_sale_manufacturing_opium_or_cocaine_or_their_derivatives = db.Column(db.Integer)
    drug_sale_manufacturing_other_dangerous_nonnarcotic_drugs = db.Column(db.Integer)
    drug_sale_manufacturing_subtotal = db.Column(db.Integer)
    drug_sale_manufacturing_synthetic_narcotics = db.Column(db.Integer)
    drunkenness = db.Column(db.Integer)
    embezzlement = db.Column(db.Integer)
    forgery_and_counterfeiting = db.Column(db.Integer)
    fraud = db.Column(db.Integer)
    gambling_all_other_gambling = db.Column(db.Integer)
    gambling_bookmaking_horse_and_sport_book = db.Column(db.Integer)
    gambling_numbers_and_lottery = db.Column(db.Integer)
    gambling_total = db.Column(db.Integer)
    human_trafficking_commercial_sex_acts = db.Column(db.Integer)
    human_trafficking_involuntary_servitude = db.Column(db.Integer)
    juvenile_disposition = db.Column(db.Integer)
    larceny_theft = db.Column(db.Integer)
    liquor_laws = db.Column(db.Integer)
    manslaughter_by_negligence = db.Column(db.Integer)
    motor_vehicle_theft = db.Column(db.Integer)
    murder_and_nonnegligent_manslaughter = db.Column(db.Integer)
    offenses_against_the_family_and_children = db.Column(db.Integer)
    prostitution_and_commercialized_vice = db.Column(db.Integer)
    prostitution_and_commercialized_vice_assisting_or_promoting_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_prostitution = db.Column(db.Integer)
    prostitution_and_commercialized_vice_purchasing_prostitution = db.Column(db.Integer)
    rape = db.Column(db.Integer)
    robbery = db.Column(db.Integer)
    runaway = db.Column(db.Integer)
    sex_offenses_except_rape_and_prostitution_and_commercialized_vice = db.Column(db.Integer)
    simple_assault = db.Column(db.Integer)
    stolen_property_buying_receiving_possessing = db.Column(db.Integer)
    suspicion = db.Column(db.Integer)
    vagrancy = db.Column(db.Integer)
    vandalism = db.Column(db.Integer)
    weapons_carrying_possessing_etc = db.Column(db.Integer)
    zero_report = db.Column(db.Integer)

class ASRRaceCount(db.Model):
    """Represents Agency Level ASR data by race"""
    __tablename__ = 'asr_race_count_agency'
    __table_args__ = (
        PrimaryKeyConstraint('offense_id', 'data_year','agency_id'),
    )

    data_year = db.Column(db.Integer)
    agency_id = db.Column(db.Integer)
    offense_id = db.Column(db.Integer)
    offense_name = db.Column(db.String)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    black = db.Column(db.Integer)
    amian = db.Column(db.Integer)
    asian = db.Column(db.Integer)
    anhopi = db.Column(db.Integer)
    chinese = db.Column(db.Integer)
    japanese = db.Column(db.Integer)
    nhopi = db.Column(db.Integer)
    other = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_specified = db.Column(db.Integer)

class ASRRaceYouthCount(db.Model):
    """Represents Agency Level ASR data by race youth"""
    __tablename__ = 'asr_race_yth_count_agency'
    __table_args__ = (
        PrimaryKeyConstraint('offense_id', 'data_year','agency_id'),
    )

    data_year = db.Column(db.Integer)
    agency_id = db.Column(db.Integer)
    offense_id = db.Column(db.Integer)
    offense_name = db.Column(db.String)
    unknown = db.Column(db.Integer)
    white = db.Column(db.Integer)
    black = db.Column(db.Integer)
    amian = db.Column(db.Integer)
    asian = db.Column(db.Integer)
    anhopi = db.Column(db.Integer)
    chinese = db.Column(db.Integer)
    japanese = db.Column(db.Integer)
    nhopi = db.Column(db.Integer)
    other = db.Column(db.Integer)
    multiple = db.Column(db.Integer)
    not_specified = db.Column(db.Integer)

class TableKeyMapping(db.Model):
    """
    Represents Tables mapping to Keys
    """
    __tablename__ = 'table_key_mapping'
    __table_args__ = (
        PrimaryKeyConstraint('table_name','key'),
    )
    def get(table_name=None):
        query = TableKeyMapping.query

        if table_name:
            query = query.filter(func.lower(TableKeyMapping.table_name) == func.lower(table_name))

        return query

    table_name = db.Column(db.String)
    column_name = db.Column(db.String)
    key = db.Column(db.String)
    ui_component = db.Column(db.String)
    ui_text = db.Column(db.String)
