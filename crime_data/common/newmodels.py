"""Models for tables not included in UCR, generated for our system

`models.py` is meant to simply reflect the tables as they exist in UCR
itself; `cdemodels.py` extends those model classes.  *These* models, on
the other hand, must actually be generated in our system.
"""
from copy import deepcopy
import logging
from psycopg2 import ProgrammingError
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import backref, relationship
from sqlalchemy.sql.elements import BinaryExpression
from sqlalchemy import func, UniqueConstraint
from sqlalchemy.sql import sqltypes
from flask_restful import abort

from crime_data.common import models
from crime_data.common.models import RefAgency, RefState, RefCounty
from crime_data.extensions import db
from sqlalchemy import or_,and_


class AgencyAnnualParticipation(db.Model):
    """Represents agency participation for a single month."""

    __tablename__ = 'cde_annual_participation'

    data_year = db.Column(db.SmallInteger, nullable=False, primary_key=True)
    state_name = db.Column(db.String)
    state_abbr = db.Column(db.String)
    agency_id = db.Column(db.Integer, nullable=False, primary_key=True)
    agency_ori = db.Column(db.String)
    agency_name = db.Column(db.String)
    agency_population = db.Column(db.BigInteger)
    population_group_code = db.Column(db.String)
    population_group = db.Column(db.String)
    reported = db.Column(db.SmallInteger, nullable=False)
    months_reported = db.Column(db.SmallInteger, nullable=False)
    reported_nibrs = db.Column(db.SmallInteger, nullable=False)
    months_reported_nibrs = db.Column(db.SmallInteger, nullable=False)

    @classmethod
    def column_is_string(cls, col_name):
        col = getattr(cls.__table__.c, col_name)
        return isinstance(col.type, sqltypes.String)

    @classmethod
    def filtered(cls, filters, args=None):
        args = args or []
        qry = cls.query
        for filter in filters:
            if isinstance(filter, BinaryExpression):
                qry = qry.filter(filter)
            else:
                (col_name, comparitor, values) = filter
                col = getattr(cls, col_name)
                if cls.column_is_string(col_name):
                    col = func.lower(col)
                operation = getattr(col, comparitor)
                qry = qry.filter(or_(operation(v) for v in values)).order_by(
                    col)
        if 'by' in args:
            for col_name in args['by'].split(','):
                col = getattr(cls, col_name)
                qry = qry.order_by(col)
        return qry


class ParticipationRate(db.Model):
    __tablename__ = 'cde_participation_rates'

    data_year = db.Column(db.SmallInteger, nullable=False, primary_key=True)
    total_population = db.Column(db.BigInteger)
    covered_population = db.Column(db.BigInteger)
    total_agencies = db.Column(db.Integer)
    reporting_agencies = db.Column(db.Integer)
    reporting_rate = db.Column(db.Float)
    nibrs_reporting_agencies = db.Column(db.Integer)
    nibrs_reporting_rate = db.Column(db.Float)
    nibrs_covered_population = db.Column(db.BigInteger)
    state_id = db.Column(db.Integer)
    county_id = db.Column(db.Integer)
    state_name = db.Column(db.String)
    county_name = db.Column(db.String)


class CreatableModel:
    @classmethod
    def create(cls):
        """Creates database table for the model, unless it already exists."""
        try:
            cls.__table__.create(db.session.bind)
        except ProgrammingError:
            pass


class NibrsIncidentRepresentation(db.Model, CreatableModel):
    __tablename__ = 'nibrs_incident_representation'

    incident_representation_id = db.Column(db.BigInteger, primary_key=True)
    incident_id = db.Column(db.BigInteger,
                            db.ForeignKey(models.NibrsIncident.incident_id))
    representation = db.Column(JSONB)
    incident = db.relationship(models.NibrsIncident,
                               uselist=False,
                               backref=backref('representation',
                                               uselist=False))

    @classmethod
    def regenerate(cls):
        """Generates or replaces cached representations for all records."""

        for incident in models.NibrsIncident.query:
            if not incident.representation:
                incident.representation = cls(incident=incident)
            incident.representation.generate()
        models.NibrsIncident.query.session.commit()

    @classmethod
    def fill(cls, batch_size=None):
        """Generates cached representations for records that lack them.

        Using a `batch_size` helps for large operations that may fail."""

        finished = False
        batch_no = 0
        while not finished:
            finished = True
            qry = models.NibrsIncident.query.filter(
                models.NibrsIncident.representation == None).limit(batch_size)
            for incident in qry:
                finished = False  # until the query comes back empty
                incident.representation = cls(incident=incident)
                incident.representation.generate()
            models.NibrsIncident.query.session.commit()
            logging.warning(
                "Batch #{batch_no} of #{batch_size} complete".format(
                    batch_no=batch_no,
                    batch_size=batch_size))
            batch_no += 1

    def generate(self):
        """Generates and caches output for a single NibrsIncident."""

        from crime_data.common import marshmallow_schemas
        _schema = marshmallow_schemas.NibrsIncidentSchema()
        self.representation = _schema.dump(self.incident).data


class RetaEstimated(db.Model):
    """
    Estimated data loaded from a CSV data file created from published data
    tables from the _Crime in the United States_ reports.
    """
    __tablename__ = 'reta_estimated'
    __table_args__ = (
        UniqueConstraint('year', 'state_id'), )

    estimate_id = db.Column(db.Integer, primary_key=True)
    year = db.Column(db.SmallInteger)
    state_id = db.Column(db.SmallInteger,
                         db.ForeignKey(RefState.state_id,
                                       deferrable=True,
                                       initially='DEFERRED'),
                         nullable=True)
    state_abbr = db.Column(db.String(2))
    population = db.Column(db.BigInteger)
    violent_crime = db.Column(db.BigInteger)
    homicide = db.Column(db.BigInteger)
    rape_legacy = db.Column(db.BigInteger)
    rape_revised = db.Column(db.BigInteger)
    robbery = db.Column(db.BigInteger)
    aggravated_assault = db.Column(db.BigInteger)
    property_crime = db.Column(db.BigInteger)
    burglary = db.Column(db.BigInteger)
    larceny = db.Column(db.BigInteger)
    motor_vehicle_theft = db.Column(db.BigInteger)
    caveats = db.Column(db.Text)

    state = relationship(RefState)

class RetaMonthAgencySubcatSummary(db.Model):
    """
    Precalculated sums for RETA Agency level data (offense level).

    Create and populate with `dba/create_reta_agency_summary.sql`
    """

    __tablename__ = 'reta_agency_offense_summary'

    reta_agency_summary_id = db.Column(db.BigInteger, autoincrement=True, primary_key=True)
    year = db.Column(db.SmallInteger)
    state_postal_abbr = db.Column(db.Text)
    state_name = db.Column(db.Text)
    agency_id = db.Column(db.BigInteger)
    agency_ori = db.Column(db.Text)
    agency_name = db.Column(db.Text)
    reported = db.Column(db.BigInteger)
    covered = db.Column(db.BigInteger)
    covering_count = db.Column(db.BigInteger)
    agency_population = db.Column(db.BigInteger)
    population_group_code = db.Column(db.Text)
    population_group = db.Column(db.Text)
    homicide_reported = db.Column(db.BigInteger)
    homicide_actual = db.Column(db.BigInteger)
    homicide_cleared = db.Column(db.BigInteger)
    homicide_juvenile_cleared = db.Column(db.BigInteger)
    rape_reported = db.Column(db.BigInteger)
    rape_actual = db.Column(db.BigInteger)
    rape_cleared = db.Column(db.BigInteger)
    rape_juvenile_cleared = db.Column(db.BigInteger)

    def get(self, state = None, agency = None, year = None, county = None):
        """Get Agency - Offense counts given some filters."""
        query = RetaMonthAgencySubcatSummary.query

        if state:
            query = query.filter(func.lower(RetaMonthAgencySubcatSummary.state_postal_abbr) == state.lower())
        if county:
            subq = (db.session.query(RetaMonthAgencySubcatSummary.agency_id)
                    .select_from(models.RefAgencyCounty)
                    .join(models.RefCounty, and_(models.RefAgencyCounty.county_id == models.RefCounty.county_id))
                    .filter(models.RefCounty.county_fips_code == county)
                )
            if year:
                subq = subq.filter(models.RefAgencyCounty.data_year == year)
            query = query.filter(RetaMonthAgencySubcatSummary.agency_id.in_(subq.subquery()))
        if agency:
            query = query.filter(RetaMonthAgencySubcatSummary.agency_ori == agency)
        if year:
            query = query.filter(RetaMonthAgencySubcatSummary.year == year)
        return query

class AgencySums(db.Model):

    __tablename__ = 'agency_sums_view'

    id = db.Column(db.BigInteger, autoincrement=True, primary_key=True)
    year = db.Column(db.SmallInteger)
    agency_id = db.Column(db.BigInteger)
    state_postal_abbr = db.Column(db.Text)
    ori = db.Column(db.Text)
    ucr_agency_name = db.Column(db.Text)
    ncic_agency_name = db.Column(db.Text)
    pub_agency_name = db.Column(db.Text)
    offense_id = db.Column(db.BigInteger) # reta_offense_subcat
    offense_code = db.Column(db.Text) # reta_offense
    offense_subcat_code = db.Column(db.Text)
    offense_subcat_name = db.Column(db.Text)
    offense_name = db.Column(db.Text)
    reported = db.Column(db.BigInteger)
    unfounded = db.Column(db.BigInteger)
    actual = db.Column(db.BigInteger)
    cleared = db.Column(db.BigInteger)
    juvenile_cleared = db.Column(db.BigInteger)
    ucr_agency_name = db.Column(db.String(100))
    ncic_agency_name = db.Column(db.String(100))
    pub_agency_name = db.Column(db.String(100))

    def get(self, state = None, agency = None, year = None, county = None):
        """Get Agency Sums given a state/year/county/agency ori, etc."""
        query = AgencySums.query

        if state:
            query = query.filter(func.lower(AgencySums.state_postal_abbr) == state.lower())
        if county:
            subq = (db.session.query(models.RefAgencyCounty.agency_id)
                    .select_from(models.RefAgencyCounty)
                    .join(models.RefCounty, and_(models.RefAgencyCounty.county_id == models.RefCounty.county_id))
                    .filter(models.RefCounty.county_fips_code == county)
                )
            if year:
                subq = subq.filter(models.RefAgencyCounty.data_year == year)
            query = query.filter(AgencySums.agency_id.in_(subq.subquery()))
        if agency:
            query = query.filter(AgencySums.ori == agency)
        if year:
            query = query.filter(AgencySums.year == year)

        # Heads up - This is going to probably make local tests fail, as our sample DB's 
        # only contain a little bit of data - ie. reported may not be 12 (ever).
        query = query.filter(AgencySums.reported == 12 ).order_by(AgencySums.year.desc()) # Agency reported 12 Months.
        #print(query) # Dubug
        return query


class RetaMonthOffenseSubcatSummary(db.Model, CreatableModel):
    """
    Precalculated sums for RETA data.

    Create and populate with `sql/create_reta_summary.sql`
    """

    __tablename__ = 'reta_month_offense_subcat_summary'

    xgrouping_sets = {'grouping_bitmap': [],
                     'year': [],
                     'month': [],
                     'offense_subcat': ['offense_subcat_code', 'offense', 'offense_code', 'offense_category', 'classification'],
                     'offense_subcat_code': ['offense_subcat', 'offense', 'offense_code', 'offense_category', 'classification'],
                     'offense': ['offense_subcat', 'offense_subcat_code', 'offense_code', 'offense_category', 'classification'],
                     'offense_code': ['offense_subcat', 'offense_subcat_code', 'offense', 'offense_category', 'classification'],
                     'offense_category': ['offense_subcat', 'offense_subcat_code', 'offense', 'offense_code', 'classification'],
                     'classification': ['offense_subcat', 'offense_subcat_code', 'offense', 'offense_code', 'offense_category'],
                     'state_name': ['state'],
                     'state': ['state_name'], }


    grouping_sets = {'grouping_bitmap': [],
                     'year': [],
                     'month': [],
                     'offense_subcat': ['offense_subcat_code', 'offense', 'offense_code', 'offense_category', 'classification'],
                     'offense_subcat_code': ['offense_subcat', 'offense', 'offense_code', 'offense_category', 'classification'],
                     'offense': ['offense_code', 'offense_category', 'classification'],
                     'offense_code': ['offense', 'offense_category', 'classification'],
                     'offense_category': ['classification'],
                     'classification': [],
                     'state_name': ['state'],
                     'state': ['state_name'], }


    # filterables *must* be in the same order as the GROUPING clause used
    # to create the `grouping_bitmap` field
    filterables = ['year',
                   'month',
                   'state_name',
                   'state',
                   'classification',
                   'offense_category',
                   'offense',
                   'offense_code',
                   'offense_subcat',
                   'offense_subcat_code',
                   ]

    reta_month_offense_subcat_summary_id = db.Column(db.BigInteger, autoincrement=True, primary_key=True)
    grouping_bitmap = db.Column(db.Integer)
    reported = db.Column(db.BigInteger)
    unfounded = db.Column(db.BigInteger)
    actual = db.Column(db.BigInteger)
    cleared = db.Column(db.BigInteger)
    juvenile_cleared = db.Column(db.BigInteger)
    year = db.Column(db.SmallInteger)
    month = db.Column(db.SmallInteger)
    offense_subcat = db.Column(db.Text)
    offense_subcat_code = db.Column(db.Text)
    offense = db.Column(db.Text)
    offense_code = db.Column(db.Text)
    offense_category = db.Column(db.Text)
    classification = db.Column(db.Text)
    state_name = db.Column(db.Text)
    state = db.Column(db.Text)

    @classmethod
    def determine_grouping(cls, filters, group_by_column_names, schema):
        """

        Return: (filters, )
        Side effect: sets visibility of fields in schema
        """

        # columns in grouping sets must be grouped together
        filtered_names = [f[0] for f in filters]
        group_columns = group_by_column_names + filtered_names
        for col in group_columns[:]:
            if col not in cls.grouping_sets:
                abort(400, message='field {} not found'.format(col))
            for sibling in cls.grouping_sets[col]:
                if sibling not in group_columns:
                    group_columns.append(sibling)

        field_names = reversed(cls.filterables)
        for (idx, field_name) in enumerate(field_names):
            show_field = field_name in group_columns
            marshmallow_field = schema.fields[field_name]
            marshmallow_field.load_only = not show_field
            bit_val = 2**idx
            if show_field:
                filters.append(cls.grouping_bitmap.op('&')(bit_val) == 0)
            else:
                filters.append(cls.grouping_bitmap.op('&')(bit_val) == bit_val)

        return filters

    @classmethod
    def column_is_string(cls, col_name):
        col = getattr(cls.__table__.c, col_name)
        return isinstance(col.type, sqltypes.String)

    @classmethod
    def filtered(cls, filters, args=None):
        args = args or []
        qry = cls.query
        for filter in filters:
            if isinstance(filter, BinaryExpression):
                qry = qry.filter(filter)
            else:
                (col_name, comparitor, values) = filter
                col = getattr(cls, col_name)
                if cls.column_is_string(col_name):
                    col = func.lower(col)
                operation = getattr(col, comparitor)
                qry = qry.filter(or_(operation(v) for v in values)).order_by(
                    col)
        if 'by' in args:
            for col_name in args['by'].split(','):
                col = getattr(cls, col_name)
                qry = qry.order_by(col)
        return qry


class CdeAgency(db.Model):
    """A class for the denormalized cde_agencies table"""
    __tablename__ = 'cde_agencies'
    __table_args__ = (UniqueConstraint('agency_id'), )

    @classmethod
    def column_is_string(cls, col_name):
        col = getattr(cls.__table__.c, col_name)
        return isinstance(col.type, sqltypes.String)

    @classmethod
    def filtered(cls, filters, args=None):
        args = args or []
        qry = cls.query
        for filter in filters:
            if isinstance(filter, BinaryExpression):
                qry = qry.filter(filter)
            else:
                (col_name, comparitor, values) = filter
                col = getattr(cls, col_name)
                if cls.column_is_string(col_name):
                    col = func.lower(col)
                operation = getattr(col, comparitor)
                qry = qry.filter(or_(operation(v) for v in values)).order_by(
                    col)
        return qry

    agency_id = db.Column(db.BigInteger, primary_key=True)
    ori = db.Column(db.String(9))
    legacy_ori = db.Column(db.String(9))
    agency_name = db.Column(db.String(100))
    agency_type_id = db.Column(db.String(1))
    agency_type_name = db.Column(db.String(100))
    # FIXME: can add associations when we need them
    tribe_id = db.Column(db.BigInteger)
    campus_id = db.Column(db.BigInteger)
    city_id = db.Column(db.BigInteger)
    city_name = db.Column(db.String(100))
    state_id = db.Column(db.SmallInteger)
    state_abbr = db.Column(db.String(2))
    agency_status = db.Column(db.String(1))
    submitting_agency_id = db.Column(db.BigInteger)
    submitting_sai = db.Column(db.String(9))
    submitting_name = db.Column(db.String(150))
    submitting_state_abbr = db.Column(db.String(2))
    start_year = db.Column(db.SmallInteger)
    dormant_year = db.Column(db.SmallInteger)
    current_year = db.Column(db.SmallInteger)
    population = db.Column(db.BigInteger)
    population_group_code = db.Column(db.String(2))
    population_group_desc = db.Column(db.String(150))
    population_source_flag = db.Column(db.String(1))
    suburban_area_flag = db.Column(db.String(1))
    months_reported = db.Column(db.SmallInteger)
    nibrs_months_reported = db.Column(db.SmallInteger)
    covered_by_id = db.Column(db.BigInteger)
    covered_by_ori = db.Column(db.String(9))
    covered_by_name = db.Column(db.String(100))
    staffing_year = db.Column(db.SmallInteger)
    total_officers = db.Column(db.Integer)
    total_civilians = db.Column(db.Integer)
