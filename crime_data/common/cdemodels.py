import abc
from collections import namedtuple
from flask_restful import abort
from sqlalchemy import and_, func, or_
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

    def __init__(self, year=None, state_id=None, county_id=None):
        self.year = year
        self.state_id = state_id
        self.county_id = county_id

    @property
    def query(self):
        qry = super().query

        if self.state_id:
            qry = qry.filter(newmodels.ParticipationRate.state_id == self.state_id)

        if self.county_id:
            qry = qry.filter(newmodels.ParticipationRate.county_id == self.county_id)

        if self.year:
            qry = qry.filter(newmodels.ParticipationRate.year == self.year)

        return qry


class CdeRefState(RefState):
    """A wrapper around the RefState model with extra finder methods"""

    counties = db.relationship('RefCounty', lazy='dynamic')

    def get(state_id=None, abbr=None, fips=None):
        """
        A method to find a state by its database ID, postal abbr or FIPS code
        """
        query = CdeRefState.query

        if state_id:
            query = query.filter(CdeRefState.state_id == state_id)
        elif abbr:
            query = query.filter(func.lower(CdeRefState.state_postal_abbr) == func.lower(abbr))
        elif fips:
            query = query.filter(CdeRefState.state_fips_code == fips[0:2])

        return query

    @property
    def current_year(self):
        try:
            return self._current_year
        except AttributeError:
            self._current_year = session.execute('select max(data_year) from cde_participation_rates where state_id = :state_id', {'state_id': self.state_id}).scalar()
            return self._current_year

    @property
    def total_agencies(self):
        return self.total_agencies_for_year(self.current_year)

    def total_agencies_for_year(self, data_year):
        return self._participation_for_year(data_year).total_agencies

    @property
    def participating_agencies(self):
        return self.participating_agencies_for_year(self.current_year)

    def participating_agencies_for_year(self, data_year):
        return self._participation_for_year(data_year).participating_agencies

    @property
    def participation_rate(self):
        return self.participating_rate_for_year(self.current_year)

    def participation_rate_for_year(self, data_year):
        return self._participation_for_year(data_year).participation_rate

    @property
    def total_population(self):
        """Returns the population for the given year"""
        return self.total_population_for_year(self.current_year)

    def total_population_for_year(self, data_year):
        """Returns the population for a given year"""
        return self._participation_for_year(data_year).total_population

    @property
    def participating_population(self):
        """Returns the population for the given year"""
        return self.participating_population_for_year(self.current_year)

    def participating_population_for_year(self, data_year):
        """Returns the population for a given year"""
        return self._participation_for_year(data_year).participating_population

    def police_officers_for_year(self, data_year):
        """Returns the number of police officers for a given year"""
        query = session.query(func.sum(models.PeEmployeeData.male_officer +
                                       models.PeEmployeeData.female_officer))
        query = (
            query.join(CdeRefAgency)
            .filter(CdeRefAgency.state_id == self.state_id)
            .filter(CdeRefAgency.agency_id == models.PeEmployeeData.agency_id)
            .filter(models.PeEmployeeData.data_year == data_year)
            .filter(models.PeEmployeeData.reported_flag == 'Y')
        )

        return query.scalar()

    @property
    def police_officers(self):
        """Returns the total police officers for the current year"""
        return self.police_officers_for_year(self.current_year)

    def _participation_for_year(self, year):
        l = CdeParticipationRate(state_id=self.state_id, year=year).query.one()
        return l

    @property
    def participation_rates(self):
        return CdeParticipationRate(state_id=self.state_id).query.order_by('year DESC').all()


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

    def __init__(self, field, year=None, state_id=None, state_abbr=None, ori=None):
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
            if self.year:
                param_dict['year'] = self.year
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
        select_query = 'SELECT b.:field, a.count, b.year FROM (SELECT :field , count, year::text'
        from_query = ' FROM :view_name'
        where_query = ' WHERE :field IS NOT NULL'

        if self.state_id:
            where_query += ' AND state_id = :state_id AND ori IS NULL'

        if self.ori:
            where_query += ' AND state_id IS NULL AND ori = :ori'

        if self.national:
            where_query += ' AND state_id is NULL AND ori is NULL'

        # Use National level aggregations to select distinct values.
        inner_where_query = ' WHERE :field IS NOT NULL AND state_id is NULL AND ori is NULL '

        if self.year:
            where_query += ' AND year = :year '
            inner_where_query += ' AND year = :year '

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
        return query

class OffenderCountView(MultiYearCountView):
    """A class for fetching the counts """

    VARIABLES = ['ethnicity', 'prop_desc_name', 'offense_name',
                 'race_code', 'location_name', 'age_num', 'sex_code']

    @property
    def view_name(self):
        """The name of the specific materialized view for this year."""
        return 'offender_counts'


class VictimCountView(MultiYearCountView):
    """A class for fetching the counts """

    VARIABLES = ['prop_desc_name', 'offense_name', 'ethnicity',
                 'resident_status_code', 'offender_relationship',
                 'circumstance_name', 'race_code', 'location_name',
                 'age_num', 'sex_code']

    @property
    def view_name(self):
        """The name of the specific materialized view."""
        return 'victim_counts'


class OffenseCountView(MultiYearCountView):
    """A class for fetching the counts broken down by offense"""

    VARIABLES = ['weapon_name', 'method_entry_code', 'num_premises_entered', 'location_name']

    @property
    def view_name(self):
        """The name of the specific materialized view."""
        return 'offense_counts'



class HateCrimeCountView(MultiYearCountView):

    VARIABLES = ['bias_name']

    @property
    def view_name(self):
        """The name of the specific materialized view."""
        return 'hc_counts'

class CargoTheftCountView(MultiYearCountView):
    """A class for fetching the counts """

    VARIABLES = ['location_name',
                 'offense_name', 'victim_type_name', 'prop_desc_name']

    @property
    def view_name(self):
        """The name of the specific materialized view."""
        return 'ct_counts'
    

    def base_query(self, field):

        query = 'SELECT b.:field, a.count, b.year FROM (SELECT :field ,stolen_value::text, recovered_value::text, year::text, count'
        query += ' FROM :view_name '
        where_query = ' WHERE :field IS NOT NULL'

        if self.state_id:
            where_query += ' AND state_id = :state_id AND ori IS NULL'

        if self.ori:
            where_query += ' AND state_id IS NULL AND ori = :ori'

        if self.national:
            where_query += ' AND state_id is NULL AND ori is NULL '

        inner_where_query = ' WHERE :field IS NOT NULL AND state_id is NULL AND ori is NULL '

        if self.year:
            where_query += ' AND year = :year '
            inner_where_query += ' AND year = :year '


        query = query + where_query + ') a '
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years WHERE year::int = :year) c) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' CROSS JOIN (SELECT year::text from nibrs_years) c) b ON (a.:field = b.:field AND a.year = b.year)'
            query = query + query_gap_fill

        query += ' ORDER by b.year, b.:field'
        return query


class OffenseSubCountView(object):

    def __init__(self, field, year=None, state_id=None, ori=None,
                 offense_name=None, state_abbr=None, explorer_offense=None):
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
            where_query += ' AND state_id is NULL AND ori IS NULL'

        if self.ori:
            where_query += ' AND state_id IS NULL AND ori = :ori'

        inner_where_query = ' WHERE :field IS NOT NULL AND state_id is NULL AND ori is NULL '

        if self.offense_name:
             where_query += ' AND offense_name IN :offense_name'
             #inner_where_query += ' AND offense_name IN :offense_name'

        if self.year:
            where_query += ' AND year = :year'
            inner_where_query += ' AND year = :year'

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
        #print(query)
        return query

class OffenseVictimCountView(OffenseSubCountView):
    """This reports subgrouped counts of a field for a given offense"""

    VARIABLES = ['resident_status_code', 'offender_relationship',
                 'circumstance_name', 'ethnicity', 'race_code',
                 'age_num', 'sex_code']

    DISTINCT_VTABLE = 'victim_counts'

    @property
    def view_name(self):
        return 'offense_victim_counts'


class OffenseOffenderCountView(OffenseSubCountView):

    VARIABLES = ['ethnicity', 'race_code', 'age_num', 'sex_code']

    DISTINCT_VTABLE = 'offender_counts'

    @property
    def view_name(self):
        return 'offense_offender_counts'

class OffenseByOffenseTypeCountView(OffenseSubCountView):
    VARIABLES = ['weapon_name', 'method_entry_code', 'num_premises_entered', 'location_name']

    DISTINCT_VTABLE = 'offense_counts'

    @property
    def view_name(self):
        return 'offense_offense_counts'

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
            where_query += ' AND state_id = :state_id AND ori IS NULL'

        if self.national:
            where_query += ' AND state_id is NULL AND ori IS NULL'

        if self.ori:
            where_query += ' AND state_id IS NULL AND ori = :ori'

        inner_where_query = ' WHERE :field IS NOT NULL AND state_id is NULL AND ori is NULL '

        if self.offense_name:
            where_query += ' AND offense_name IN :offense_name'
            inner_where_query += ' AND offense_name IN :offense_name'

        if self.year:
            where_query += ' AND year = :year'
            inner_where_query += ' AND year = :year'

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
        return query

    @property
    def view_name(self):
        return 'offense_ct_counts'


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
            where_query += ' AND state_id = :state_id AND ori IS NULL'

        if self.national:
            where_query += ' AND state_id is NULL AND ori IS NULL'

        if self.ori:
            where_query += ' AND state_id IS NULL AND ori = :ori'

        inner_where_query = ' WHERE :field IS NOT NULL AND state_id is NULL AND ori is NULL '

        if self.offense_name:
            where_query += ' AND offense_name IN :offense_name'
            inner_where_query += ' AND offense_name IN :offense_name'

        if self.year:
            where_query += ' AND year = :year'
            inner_where_query += ' AND year = :year'

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
        return query

    @property
    def view_name(self):
        return 'offense_hc_counts'
