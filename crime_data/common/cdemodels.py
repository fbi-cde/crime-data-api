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


#class CdeRefState(RefState):
#    pass

#class CdeRefCounty(RefCounty):
#    pass


class CdeNibrsAge(models.NibrsAge):
    pass


class CdeNibrsOffenseType(models.NibrsOffenseType):
    pass


class CdeNibrsWeapon(models.NibrsWeapon):
    pass


class CdeNibrsWeaponType(models.NibrsWeaponType):
    pass


class CdeRefRace(models.RefRace):
    pass


class CdeRefCity(models.RefCity):
    pass


class CdeRetaMonthOffenseSubcat(models.RetaMonthOffenseSubcat):
    pass


class CdeRefAgencyCounty(models.RefAgencyCounty):
    """A wrapper around the RefAgencyCounty model"""

    @staticmethod
    def current_year():
        """Returns the current year for the agency/county mappings."""
        return session.query(func.max(CdeRefAgencyCounty.data_year)).scalar()


# CdeParticipationRecord = namedtuple('CdeParticipationRecord', ['year', 'total_agencies', 'reporting_agencies', 'reporting_rate', 'total_population', 'covered_population'])

class CdeParticipationRate(newmodels.ParticipationRate):
    """Class for querying the cde_participation_rate"""

    def __init__(self, year=None, state_id=None, state_abbr=None, county_id=None):
        self.year = year
        self.state_id = state_id
        self.state_abbr = state_abbr
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
            query = query.filter(CdeRefState.state_postal_abbr == abbr)
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


class CdeRefCounty(RefCounty):
    """A wrapper around the RefCounty model with extra methods."""

    def get(county_id=None, fips=None, name=None):
        """Find matching counties by id, fips code or name."""
        query = CdeRefCounty.query

        if county_id:
            query = query.filter(CdeRefCounty.county_id == county_id)
        elif fips:
            if isinstance(fips, str) and len(fips) == 5:
                state = CdeRefState.get(fips=fips).one()
                # This is because FBI stores county FIPS as string of
                # int coercion of county FIPS code so that full FIPS
                # 05003 you'd expect is stored as '3'
                county_fips = str(int(fips[2:5]))
                query = query.filter(
                    and_(CdeRefCounty.state_id == state.state_id,
                         CdeRefCounty.county_fips_code == county_fips))
            else:
                raise ValueError('The FIPS code must be a 5-character string')
        elif name:
            query = query.filter(func.lower(CdeRefCounty.county_name) ==
                                 func.lower(name))

        return query

    @property
    def current_year(self):
        try:
            return self._current_year
        except AttributeError:
            self._current_year = session.execute('select max(data_year) from cde_participation_rates where county_id = :county_id', {'county_id': self.county_id}).scalar()
            return self._current_year

    @property
    def state_name(self):
        """Returns the state name or None if no state record is found."""
        if self.state is None:
            None
        else:
            self.state.name

    @property
    def state_abbr(self):
        """Returns the state postal abbrev or None is no state record is found."""

        if self.state is None:
            None
        else:
            self.state.state_postal_abbr

    @property
    def fips(self):
        """Builds a FIPS code string for the county."""
        # the int coercion is necessary because of how FBI stores county FIPS
        return '{}{:03d}'.format(self.state.state_fips_code,
                                 int(self.county_fips_code))

    def total_agencies_for_year(self, data_year):
        """Counts the number of agencies for that county in a year."""
        return self._participation_for_year(data_year).total_agencies

    @property
    def participating_agencies(self):
        """Returns the number of agencies for the most recent year"""
        return self.participating_agencies_for_year(self.current_year)

    def participating_agencies_for_year(self, data_year):
        """Counts the number of agencies for that county in a year."""
        return self._participation_for_year(data_year).participating_agencies

    @property
    def participating_population(self):
        """Returns the population for the given year"""
        return self.participating_population_for_year(self.current_year)

    def participating_population_for_year(self, data_year):
        """Returns the population for a given year"""
        return self._participation_for_year(data_year).participating_population

    @property
    def total_agencies(self):
        """Returns the number of agencies for the most recent year"""
        return self.total_agencies_for_year(self.current_year)

    def total_population_for_year(self, data_year):
        """Returns the population for a given year"""
        return self._participation_for_year(data_year).total_population

    @property
    def total_population(self):
        """Returns the most recent reported population for the county"""
        return self.total_population_for_year(self.current_year)

    def police_officers_for_year(self, data_year):
        """Returns the number of police officers for a given year"""
        query = session.query(func.sum(models.PeEmployeeData.male_officer +
                                       models.PeEmployeeData.female_officer))
        query = (
            query.join(CdeRefAgency)
            .join(CdeRefAgencyCounty)
            .filter(CdeRefAgencyCounty.data_year == data_year)
            .filter(CdeRefAgencyCounty.county_id == self.county_id)
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
        """Internal method for loading the participation data"""
        l = CdeParticipationRate(county_id=self.county_id, year=year).query.one()
        return l


class CdeRefAgency(models.RefAgency):
    def get(ori=None):
        # Base Query
        query = CdeRefAgency.query

        # Get ONE ORI.
        if ori:
            query = query.filter(CdeRefAgency.ori == ori)

        return query

    pass


class CdeNibrsEthnicity(models.NibrsEthnicity):
    pass


class CdeNibrsVictim(models.NibrsVictim):
    pass


class CdeNibrsOffender(models.NibrsOffender):
    pass


class CdeNibrsMonth(models.NibrsMonth):
    pass


class CdeNibrsOffense(models.NibrsOffense):
    pass


class CdeNibrsLocationType(models.NibrsLocationType):
    pass


class CdeNibrsIncident(models.NibrsIncident):
    pass


class CdeRetaMonth(models.RetaMonth):
    pass


class CdeCrimeType(models.CrimeType):
    pass


class CdeRetaOffenseCategory(models.RetaOffenseCategory):
    crime_type = db.relationship(CdeCrimeType, backref='categories')


class CdeRetaOffense(models.RetaOffense):

    category = db.relationship(CdeRetaOffenseCategory, backref='offenses')


class CdeRetaOffenseSubcat(models.RetaOffenseSubcat):

    offense = db.relationship(CdeRetaOffense, backref='subcategories')


class CdeOffenseClassification(models.OffenseClassification):

    offense = db.relationship(CdeRetaOffense, backref='classifications')


class JoinedTable:

    PREFIX_SEPARATOR = '.'

    def __init__(self, table, prefix=None, join=None, parent=None):
        self.table = table
        self.prefix = prefix
        self.join = join
        self.parent = parent

    def columns(self):
        """Yield all this model's columns."""

        if hasattr(self.table, '_aliased_insp'):
            column_source = self.table._aliased_insp.class_
            # TODO: Relying on underscores is scary.
        else:
            column_source = self.table
        for attr_name in dir(column_source):
            # distinguish actual columns from other model attributes
            try:
                col = getattr(self.table, attr_name)
                if hasattr(col, 'key') and hasattr(col, 'prop') and hasattr(
                        col, 'base_columns'):
                    yield col
            except ArgumentError:
                pass

    def map(self):
        """Yield (column_name, column) for this table."""

        for col in self.columns():
            column_names = [col.key, ]
            if col.key in Fields.get_simplified_column_names():
                column_names.append(Fields.get_simplified_column_names()[
                    col.key])
            for column_name in column_names:
                if self.prefix:
                    alias = '{}{}{}'.format(self.prefix, self.PREFIX_SEPARATOR,
                                            column_name)
                else:
                    alias = column_name
                yield (alias, col)


class TableFamily:
    """
    Base class for Queries on the CDE database.
    """

    def __init__(self):
        self._map = {}

    @classmethod
    def get_tables(cls, parent):
        return tables

    @property
    def map(self):
        """Builds a map of DB column names for Query."""
        if not self._map:
            self._build_map()
        return self._map

    @property
    def filter_columns(self):
        out = []
        type_map = {
            st.Integer: {'type': 'integer'},
            st.BigInteger: {'type': 'integer'},
            st.SmallInteger: {'type': 'integer'},
            st.Boolean: {'type': 'boolean'},
            st.DateTime: {'type': 'string',
                          'format': 'date-time'},
            st.String: {'type': 'string'}
        }
        for (name, (table, col)) in self.map.items():
            sqla_col = list(col.base_columns)[0]
            sql_type = sqla_col.type.__class__
            field = type_map[sql_type].copy()
            field['name'] = name

            if hasattr(sqla_col.type, 'length'):
                field['maxLength'] = sqla_col.type.length

            out.append(field)
        return out

    @property
    def input_args(self):
        """Returns a hash of names: type for Swagger"""
        out = {key: pair[1].type for key, pair in self.map.items()}
        return out

    def base_query(self):
        """Gets root Query, based on class's base_table"""
        return db.session.query(self.base_table.table)

    def _is_string(self, col):
        col0 = list(col.base_columns)[0]
        return issubclass(col0.type.python_type, str)

    def _col(self, col_name):
        """Gets DB mapped column name."""
        if col_name not in self.map:
            abort(400, message='field {} not found'.format(col_name))
        return self.map[col_name]

    def _post_process(self, qry):
        """Applies any nescessary post-processing to query."""
        return qry

    def filtered(self, filters, args=None):
        """Applies requested Query filters. Returns SQLAlchemy Query object."""
        qry = self.base_query()
        self.joined = {self.base_table,
                       }  # Messy way to track what has been joined
        for (col_name, comparitor, values) in filters:
            (joined_tbl, col) = self._col(col_name)
            qry = self.join(qry, joined_tbl)
            if self._is_string(col):
                col = func.lower(col)
                values = [val.lower() for val in values]
            operation = getattr(col, comparitor)
            qry = qry.filter(or_(operation(v) for v in values))
        qry = self._post_process(qry)
        return qry

    def join(self, qry, table):
        """Joins `table` (JoinedTable instance) if not already present"""
        if table not in self.joined:
            if table.parent:
                qry = self.join(qry, table.parent)
            if table.join is None:
                qry = qry.outerjoin(table.table)
            else:
                qry = qry.outerjoin(table.table, table.join)
            self.joined.add(table)
        return qry

    def group_by(self, qry, group_columns):
        """Adds GROUP BY statements to Query. """
        for col_name in group_columns:
            (table, col) = self._col(col_name)
            qry = self.join(qry, table)
            if col_name in Fields.get_db_column_names():
                col = label(col_name, col)
            elif col_name in Fields.get_simplified_column_names():
                col = label(Fields.get_simplified_column_names()[col_name],
                            col)
            qry = qry.add_columns(col)
            qry = qry.group_by(col).order_by(col)
        return qry

    def _build_map(self):
        """Create a record of SQLAlchemy columns by column name."""
        self._map = {}
        tables = [self.base_table, ] + self.tables
        for table in tables:
            for (alias, col) in table.map():
                # this alias includes the baked-in table name
                if alias not in self._map:
                    self._map[alias] = (table, col)
        # self.print_map() # - uncomment to generate JSON

    def query(self):
        """Returns a finalized SQLAlchemy Query object"""
        self._build_map()
        # self.print_map() # - uncomment to generate JSON
        try:
            qry = self.base_query()
            for table in self.tables:
                if table.join is None:
                    qry = qry.outerjoin(table.table)
                else:
                    qry = qry.outerjoin(table.table, table.join)
        except Exception as e:
            session.rollback()
            session.close()
            raise e

        return qry

    def print_map(self):
        """
        Quick-and-dirty output into stdout of filter columns for swagger.

        TODO: should be less quick and dirty!
        """

        template = """{{
                      "name": "{name}",
                      "in": "query",
                      "type": "{type}",
                      "required": false
                    }}, """

        print('\n\nmappings for {}\n\n'.format(self))
        types = {int: 'integer', bool: 'boolean', }
        for (name, (table, col)) in sorted(self.map.items()):
            sqla_col = list(col.base_columns)[0]
            typ = types.get(sqla_col.type.python_type, 'string')
            print(template.format(name=name, type=typ))


class AgencyTableFamily(TableFamily):
    @classmethod
    def get_tables(cls, parent):
        tables = []
        _agency = JoinedTable(models.RefAgency, parent=parent)
        tables.append(_agency)
        tables.append(JoinedTable(models.RefAgencyType, parent=_agency)),

        _state = JoinedTable(models.RefState, parent=_agency)
        tables.append(_state),
        _county_associations = JoinedTable(models.RefAgencyCounty,
                                           parent=_agency)
        tables.append(_county_associations)
        tables.append(JoinedTable(models.RefCounty,
                                  parent=_county_associations))
        tables.append(JoinedTable(models.RefCity, parent=_agency))
        _division = JoinedTable(models.RefDivision, parent=_state)
        tables.append(_division)
        tables.append(JoinedTable(models.RefRegion, parent=_division))
        tables.append(JoinedTable(models.RefSubmittingAgency,  # prefix?
                                  join=(models.RefAgency.agency_id ==
                                        models.RefSubmittingAgency.agency_id)))
        tables.append(JoinedTable(models.RefFieldOffice, parent=_agency))
        tables.append(JoinedTable(
            models.RefPopulationFamily,
            parent=_agency,
            join=(models.RefAgency.population_family_id ==
                  models.RefPopulationFamily.population_family_id), ))
        return tables


class IncidentTableFamily(TableFamily):
    """""
    Base Class for Incident table based queries.
    """""

    # List of all associated tables.
    tables = []

    # Root Table => Incidents
    base_table = JoinedTable(models.NibrsIncident)

    # Build Table aliases for Query.
    victim_race = aliased(models.RefRace)
    victim_age = aliased(models.NibrsAge)
    victim_ethnicity = aliased(models.NibrsEthnicity)
    offender_race = aliased(models.RefRace)
    offender_age = aliased(models.NibrsAge)
    offender_ethnicity = aliased(models.NibrsEthnicity)
    arrestee_race = aliased(models.RefRace)
    arrestee_age = aliased(models.NibrsAge)
    arrestee_ethnicity = aliased(models.NibrsEthnicity)

    # Create JOINs for query.
    offense = JoinedTable(models.NibrsOffense)
    offender = JoinedTable(models.NibrsOffender,
                           prefix='offender',
                           parent=offense)
    victim = JoinedTable(models.NibrsVictim, prefix='victim', parent=offense)
    victim_injury = JoinedTable(models.NibrsVictimInjury,
                                prefix='victim',
                                parent=victim)
    injury = JoinedTable(models.NibrsInjury,
                         prefix='victim',
                         parent=victim_injury)
    victim_offender_rel = JoinedTable(models.NibrsVictimOffenderRel,
                                      prefix='victim',
                                      parent=victim)
    relationship_ = JoinedTable(models.NibrsRelationship,
                                prefix='victim',
                                parent=victim_offender_rel)
    offense_weapon = JoinedTable(models.NibrsWeapon,
                                 prefix='offense',
                                 parent=offense)
    weapon = JoinedTable(models.NibrsWeaponType,
                         prefix='offense',
                         parent=offense_weapon)
    criminal_act = JoinedTable(models.NibrsCriminalAct,
                               prefix='offense',
                               parent=offense)
    criminal_act_type = JoinedTable(models.NibrsCriminalActType,
                                    prefix='offense',
                                    parent=criminal_act)
    arrestee = JoinedTable(models.NibrsArrestee,
                           prefix='arrestee',
                           parent=offense,
                           join=(models.NibrsIncident.incident_id ==
                                 models.NibrsArrestee.incident_id))
    property_ = JoinedTable(models.NibrsProperty)

    tables.append(offense)

    tables.append(JoinedTable(models.NibrsOffenseType, parent=offense)),

    tables.extend(AgencyTableFamily.get_tables(None))
    tables.append(JoinedTable(models.NibrsClearedExcept))
    offender = JoinedTable(models.NibrsOffender,
                           prefix='offender',
                           parent=offense)
    tables.append(offender)

    victim = JoinedTable(models.NibrsVictim, prefix='victim', parent=offense)

    tables.append(victim)

    victim_injury = JoinedTable(models.NibrsVictimInjury,
                                prefix='victim',
                                parent=victim)
    injury = JoinedTable(models.NibrsInjury,
                         prefix='victim',
                         parent=victim_injury)
    tables.append(victim_injury)
    tables.append(injury)

    victim_offender_rel = JoinedTable(models.NibrsVictimOffenderRel,
                                      prefix='victim',
                                      parent=victim)
    relationship_ = JoinedTable(models.NibrsRelationship,
                                prefix='victim',
                                parent=victim_offender_rel)
    tables.append(victim_offender_rel)
    tables.append(relationship_)

    offense_weapon = JoinedTable(models.NibrsWeapon,
                                 prefix='offense',
                                 parent=offense)
    weapon = JoinedTable(models.NibrsWeaponType,
                         prefix='offense',
                         parent=offense_weapon)
    tables.append(offense_weapon)
    tables.append(weapon)

    criminal_act = JoinedTable(models.NibrsCriminalAct,
                               prefix='offense',
                               parent=offense)
    criminal_act_type = JoinedTable(models.NibrsCriminalActType,
                                    prefix='offense',
                                    parent=criminal_act)
    tables.append(criminal_act)
    tables.append(criminal_act_type)

    arrestee = JoinedTable(models.NibrsArrestee,
                           prefix='arrestee',
                           parent=offense,
                           join=(models.NibrsIncident.incident_id ==
                                 models.NibrsArrestee.incident_id))
    tables.append(arrestee)
    tables.append(JoinedTable(offender_age,
                              join=(models.NibrsOffender.age_id ==
                                    offender_age.age_id),
                              prefix='offender',
                              parent=offender))
    tables.append(JoinedTable(offender_race,
                              join=(models.NibrsOffender.race_id ==
                                    offender_race.race_id),
                              prefix='offender',
                              parent=offender))
    tables.append(JoinedTable(offender_ethnicity,
                              join=(models.NibrsOffender.ethnicity_id ==
                                    offender_ethnicity.ethnicity_id),
                              prefix='offender',
                              parent=offender))
    tables.append(JoinedTable(victim_age,
                              join=(models.NibrsVictim.age_id ==
                                    victim_age.age_id),
                              prefix='victim',
                              parent=victim))
    tables.append(JoinedTable(victim_race,
                              join=(models.NibrsVictim.race_id ==
                                    victim_race.race_id),
                              prefix='victim',
                              parent=victim))
    tables.append(JoinedTable(victim_ethnicity,
                              join=(models.NibrsVictim.ethnicity_id ==
                                    victim_ethnicity.ethnicity_id),
                              prefix='victim',
                              parent=victim))
    tables.append(JoinedTable(arrestee_age,
                              join=(models.NibrsArrestee.age_id ==
                                    arrestee_age.age_id),
                              prefix='arrestee',
                              parent=arrestee))
    tables.append(JoinedTable(arrestee_race,
                              join=(models.NibrsArrestee.race_id ==
                                    arrestee_race.race_id),
                              prefix='arrestee',
                              parent=arrestee))
    tables.append(JoinedTable(arrestee_ethnicity,
                              join=(models.NibrsArrestee.ethnicity_id ==
                                    arrestee_ethnicity.ethnicity_id),
                              prefix='arrestee',
                              parent=arrestee))

    tables.append(property_)
    tables.append(JoinedTable(models.NibrsPropLossType, parent=property))
    # TODO: property_desc, suspected_drug
    tables.append(JoinedTable(models.NibrsLocationType,
                              parent=offense,
                              join=(models.NibrsOffense.location_id ==
                                    models.NibrsLocationType.location_id), ))

    # TODO: COUNTY, TRIBE

    def base_query(self):
        """Gets root Query, based on class's base_table"""
        return db.session.query(self.base_table.table)


class CachedIncidentCountTableFamily(TableFamily):

    base_table = JoinedTable(newmodels.RetaMonthOffenseSubcatSummary)
    tables = []


class IncidentCountTableFamily(TableFamily):
    """""
    Base class for any RETA Summary data queries.
    """""

    # List of all associated tables.
    tables = []

    # Root table => RetaMonthOffenseSubcat
    base_table = JoinedTable(models.RetaMonthOffenseSubcat)

    # Create JOINs for query.
    month = JoinedTable(models.RetaMonth)
    subcat = JoinedTable(models.RetaOffenseSubcat)
    offense = JoinedTable(models.RetaOffense, parent=subcat)

    # Append all Joined tables to list of table for query.
    tables.append(month)
    tables.append(subcat)
    tables.append(offense)
    tables.append(JoinedTable(models.OffenseClassification, parent=offense))
    tables.append(JoinedTable(models.RetaOffenseCategory, parent=offense))
    tables.extend(AgencyTableFamily.get_tables(month))

    def base_query(self):
        return db.session.query(
            label('actual_count',
                  func.sum(models.RetaMonthOffenseSubcat.actual_count)), label(
                      'reported_count',
                      func.sum(models.RetaMonthOffenseSubcat.reported_count)),
            label('unfounded_count',
                  func.sum(models.RetaMonthOffenseSubcat.unfounded_count)),
            label('cleared_count',
                  func.sum(models.RetaMonthOffenseSubcat.cleared_count)),
            label('juvenile_cleared_count',
                  func.sum(
                      models.RetaMonthOffenseSubcat.juvenile_cleared_count), ))

# ASR_MONTH is not broken down by race or crime and should have
# its own endpoint


# This tree of subcategory-offense-category is shared by the following three families
category_tables = []
_subcat = JoinedTable(models.AsrOffenseSubcat)
category_tables.append(_subcat)
_offense = JoinedTable(models.AsrOffense, parent=_subcat)
category_tables.append(_offense)
_category = JoinedTable(models.AsrOffenseCategory, parent=_offense)
category_tables.append(_category)


class ArrestsByRaceTableFamily(TableFamily):

    base_table = JoinedTable(models.AsrRaceOffenseSubcat)

    tables = []
    month = JoinedTable(models.AsrMonth)
    tables.append(month)
    race = JoinedTable(models.RefRace)
    tables.append(race)

    tables.extend(category_tables)
    tables.extend(AgencyTableFamily.get_tables(month))

    def base_query(self):
        return db.session.query(label('arrest_count', func.sum(
            models.AsrRaceOffenseSubcat.arrest_count)))


class ArrestsByEthnicityTableFamily(TableFamily):

    base_table = JoinedTable(models.AsrEthnicityOffense)

    tables = []
    month = JoinedTable(models.AsrMonth)
    tables.append(month)
    ethnicity = JoinedTable(models.AsrEthnicity)
    tables.append(ethnicity)

    tables.extend(category_tables)
    tables.extend(AgencyTableFamily.get_tables(month))

    def base_query(self):
        return db.session.query(label('arrest_count', func.sum(
            models.AsrEthnicityOffense.arrest_count)))


class ArrestsByAgeSexTableFamily(TableFamily):

    base_table = JoinedTable(models.AsrAgeSexSubcat)

    tables = []
    month = JoinedTable(models.AsrMonth)
    tables.append(month)
    age_range = JoinedTable(models.AsrAgeRange)
    tables.append(age_range)

    tables.extend(category_tables)
    tables.extend(AgencyTableFamily.get_tables(month))

    def base_query(self):
        return db.session.query(label('arrest_count', func.sum(
            models.AsrAgeSexSubcat.arrest_count)))


class ArsonTableFamily(TableFamily):

    base_table = JoinedTable(models.ArsonMonthBySubcat)

    tables = []
    month = JoinedTable(models.ArsonMonth)
    tables.append(month)
    subcategory = JoinedTable(models.ArsonSubcategory)
    tables.append(subcategory)
    tables.append(JoinedTable(models.ArsonSubclassification,
                              parent=subcategory))

    tables.extend(AgencyTableFamily.get_tables(month))

    def base_query(self):
        return db.session.query(
            label('reported_count',
                  func.sum(models.ArsonMonthBySubcat.reported_count)),
            label('unfounded_count',
                  func.sum(models.ArsonMonthBySubcat.unfounded_count)), label(
                      'actual_count',
                      func.sum(models.ArsonMonthBySubcat.actual_count)), label(
                          'cleared_count',
                          func.sum(models.ArsonMonthBySubcat.cleared_count)),
            label('juvenile_cleared_count',
                  func.sum(models.ArsonMonthBySubcat.juvenile_cleared_count)),
            label('uninhabited_count',
                  func.sum(models.ArsonMonthBySubcat.uninhabited_count)),
            label('est_damage_value',
                  func.sum(models.ArsonMonthBySubcat.est_damage_value)))



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
            self.state_id = CdeRefState.get(abbr=state_abbr.upper()).one().state_id
            
        self.ori = ori
        self.field = field
        self.national = False
        if self.state_id is None and self.ori is None:
            self.national = True

    def get_field_table(self, field):
        if field in ['weapon_name']:
            return ('nibrs_weapon_type','weapon_name')

        if field in ['method_entry_code']:
            return ('nibrs_offense_denorm_2012','method_entry_code')

        if field in ['num_premises_entered']:
            return ('nibrs_offense_denorm_2012', 'num_premises_entered')

        if field in ['bias_name']:
            return ('nibrs_bias_list','bias_name')

        if field in ['resident_status_code']:
            return ('nibrs_victim_denorm_2012','resident_status_code')

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
            return ('nibrs_victim_denorm_2012','sex_code')

        if field in ['age_num']:
            return ('victim_counts_2012','age_num')

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

        if self.year:
            where_query += ' AND year = :year '

        query = select_query + from_query + where_query

        query += ') a '
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name WHERE year = :year ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field AND a.year = b.year)'
            query = query + query_gap_fill
        query += ' ORDER by a.year, a.:field'
        #SELECT * FROM (SELECT offense_name , count, year::text FROM victim_counts WHERE offense_name IS NOT NULL AND offense_name = 'Robbery' AND state_id is NULL AND county_id is NULL AND year = 2012 ) a  RIGHT JOIN (SELECT DISTINCT offense_name from nibrs_offense_type) b ON (a.offense_name = b.offense_name)
        #print(query)
        return query

#SELECT * FROM (SELECT  bias_name , count, year::text FROM hc_counts WHERE bias_name IS NOT NULL AND state_id = 3 AND county_id IS NULL) a  RIGHT JOIN (SELECT DISTINCT nibrs_bias_list.bias_name,year from nibrs_bias_list RIGHT JOIN (SELECT year::text, bias_name from hc_counts) c ON (c.bias_name = nibrs_bias_list.bias_name)) b ON (a.bias_name = b.bias_name)

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
        query += ' WHERE :field IS NOT NULL'

        if self.state_id:
            query += ' AND state_id = :state_id AND ori IS NULL'

        if self.ori:
            query += ' AND state_id IS NULL AND ori = :ori'

        if self.national:
            query += ' AND state_id is NULL AND ori is NULL '

        if self.year:
            query += ' AND year = :year '

        query += ') a '
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name WHERE year = :year ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field AND a.year = b.year)'
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
            self.state_id = CdeRefState.get(abbr=state_abbr.upper()).one().state_id

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
            return ('nibrs_offense_denorm_2012','method_entry_code')

        if field in ['num_premises_entered']:
            return ('nibrs_offense_denorm_2012', 'num_premises_entered')

        if field in ['bias_name']:
            return ('nibrs_bias_list','bias_name')

        if field in ['resident_status_code']:
            return ('nibrs_victim_denorm_2012','resident_status_code')

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
            return ('nibrs_victim_denorm_2012','sex_code')

        if field in ['age_num']:
            return ('victim_counts_2012','age_num')

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
        query += ' WHERE :field IS NOT NULL'

        if self.state_id:
            query += ' AND state_id = :state_id '

        if self.national:
            query += ' AND state_id is NULL AND ori IS NULL'

        if self.ori:
            query += ' AND state_id IS NULL AND ori = :ori'

        if self.offense_name:
             query += ' AND offense_name IN :offense_name'

        if self.year:
            query += ' AND year = :year'

        query += ') a '
        
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name WHERE year = :year ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field AND a.year = b.year)'
            query = query + query_gap_fill

        if self.explorer_offense:
            query += ' GROUP by b.year, b.:field, offense_name'

        query += ' ORDER by b.year, offense_name, b.:field'


        return query

        #SELECT * from (SELECT year::text, offense_name, sex_code, count FROM offense_victim_counts WHERE sex_code IS NOT NULL AND state_id = 3 ) a  RIGHT JOIN (SELECT DISTINCT sex_code from nibrs_victim) b ON (a.sex_code= b.sex_code) ORDER by a.year, a.offense_name, a.sex_code;


class OffenseVictimCountView(OffenseSubCountView):
    """This reports subgrouped counts of a field for a given offense"""

    VARIABLES = ['resident_status_code', 'offender_relationship',
                 'circumstance_name', 'ethnicity', 'race_code',
                 'age_num', 'sex_code']

    @property
    def view_name(self):
        return 'offense_victim_counts'


class OffenseOffenderCountView(OffenseSubCountView):

    VARIABLES = ['ethnicity', 'race_code', 'age_num', 'sex_code']

    @property
    def view_name(self):
        return 'offense_offender_counts'

class OffenseByOffenseTypeCountView(OffenseSubCountView):
    VARIABLES = ['weapon_name', 'method_entry_code', 'num_premises_entered', 'location_name']

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
        query += ' WHERE :field IS NOT NULL'

        if self.state_id:
            query += ' AND state_id = :state_id AND ori IS NULL'

        if self.national:
            query += ' AND state_id is NULL AND ori IS NULL'

        if self.ori:
            query += ' AND state_id IS NULL AND ori = :ori'

        if self.offense_name:
            query += ' AND offense_name IN :offense_name'

        if self.year:
            query += ' AND year = :year'

        query += ') a '
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name WHERE year = :year ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field AND a.year = b.year)'
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
        query += ' WHERE :field IS NOT NULL'

        if self.state_id:
            query += ' AND state_id = :state_id AND ori IS NULL'

        if self.national:
            query += ' AND state_id is NULL AND ori IS NULL'

        if self.ori:
            query += ' AND state_id IS NULL AND ori = :ori'

        if self.offense_name:
            query += ' AND offense_name IN :offense_name'

        if self.year:
            query += ' AND year = :year'

        # if self.explorer_offense:
        #     query += ' GROUP by year, :field'

        query += ') a '
        join_table,join_field = self.get_field_table(field)
        if join_field:
            if self.year:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field,c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name WHERE year = :year ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field)'
            else:
                query_gap_fill = ' RIGHT JOIN (SELECT DISTINCT ' + join_table + '.' + join_field + ' AS :field, c.year from ' + join_table + ' RIGHT JOIN (SELECT year::text, :view_name.:field from :view_name ORDER BY year DESC) c ON (c.:field = ' + join_table +'.' + join_field + ')) b ON (a.:field = b.:field AND a.year = b.year)'
            query = query + query_gap_fill

        if self.explorer_offense:
            query += ' GROUP by b.year, b.:field, offense_name'

        query += ' ORDER by b.year, b.:field'
        return query

    @property
    def view_name(self):
        return 'offense_hc_counts'
