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
from crime_data.common.base import ExplorerOffenseMapping
from crime_data.common.models import RefAgency, RefState, RefCounty
from crime_data.extensions import db
from sqlalchemy import or_,and_

class FilterableModel:
    @classmethod
    def column_is_string(cls, col_name):
        col = getattr(cls.__table__.c, col_name)
        return isinstance(col.type, sqltypes.String)

    @classmethod
    def filtered(cls, filters, args=None):
        args = args or []
        qry = cls.query

        # This could be generalized to other places in the future
        if 'fields' in args:
            fields = args['fields'].split(',')
            qry = qry.with_entities(*fields).select_from(cls)

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


class AgencyParticipation(db.Model, FilterableModel):
    """Represents agency participation for a single month."""

    __tablename__ = 'agency_participation'

    year = db.Column(db.SmallInteger, nullable=False, primary_key=True)
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
    nibrs_reported = db.Column(db.SmallInteger, nullable=False)
    nibrs_months_reported = db.Column(db.SmallInteger, nullable=False)
    covered = db.Column(db.SmallInteger)
    participated = db.Column(db.SmallInteger)
    nibrs_participated = db.Column(db.SmallInteger)


class ArsonSummary(db.Model):
    __tablename__ = 'arson_summary'

    arson_summary_id = db.Column(db.Integer, nullable=False, primary_key=True)
    grouping_bitmap = db.Column(db.Integer)
    year = db.Column(db.SmallInteger)
    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.Text)
    agency_id = db.Column(db.Integer)
    ori = db.Column(db.Text)
    subcategory_code = db.Column(db.Text)
    subcategory_name = db.Column(db.Text)
    reported = db.Column(db.Integer)
    unfounded = db.Column(db.Integer)
    actual = db.Column(db.Integer)
    cleared = db.Column(db.Integer)
    juvenile_cleared = db.Column(db.Integer)
    uninhabited = db.Column(db.Integer)
    est_damage_value = db.Column(db.Integer)


class ParticipationRate(db.Model):
    __tablename__ = 'participation_rates'

    participation_id = db.Column(db.Integer, nullable=False, primary_key=True)
    year = db.Column(db.SmallInteger, nullable=False)
    state_id = db.Column(db.Integer,
                         db.ForeignKey(RefState.state_id,
                                       deferrable=True,
                                       initially='DEFERRED'),
                         nullable=True)
    county_id = db.Column(db.Integer,
                          db.ForeignKey(RefCounty.county_id,
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=True)
    state_name = db.Column(db.String)
    county_name = db.Column(db.String)
    total_agencies = db.Column(db.Integer)
    participating_agencies = db.Column(db.Integer)
    participation_rate = db.Column(db.Float)
    nibrs_participating_agencies = db.Column(db.Integer)
    nibrs_participation_rate = db.Column(db.Float)
    covered_agencies = db.Column(db.Integer)
    covered_rate = db.Column(db.Float)
    total_population = db.Column(db.BigInteger)
    participating_population = db.Column(db.BigInteger)
    nibrs_participating_population = db.Column(db.BigInteger)


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


class ArrestsNational(db.Model):
    """Estimated data about national arrest totals"""
    __tablename__ = 'asr_national'

    id = db.Column(db.BigInteger, autoincrement=True, primary_key=True)
    year = db.Column(db.SmallInteger)
    population = db.Column(db.BigInteger)
    total_arrests = db.Column(db.BigInteger)
    homicide = db.Column(db.BigInteger)
    rape = db.Column(db.BigInteger)
    robbery = db.Column(db.BigInteger)
    aggravated_assault = db.Column(db.BigInteger)
    burglary = db.Column(db.BigInteger)
    larceny = db.Column(db.BigInteger)
    motor_vehicle_theft = db.Column(db.BigInteger)
    arson = db.Column(db.BigInteger)
    violent_crime = db.Column(db.BigInteger)
    property_crime = db.Column(db.BigInteger)
    other_assault = db.Column(db.BigInteger)
    forgery = db.Column(db.BigInteger)
    fraud = db.Column(db.BigInteger)
    embezzlement = db.Column(db.BigInteger)
    stolen_property = db.Column(db.BigInteger)
    vandalism = db.Column(db.BigInteger)
    weapons = db.Column(db.BigInteger)
    prostitution = db.Column(db.BigInteger)
    other_sex_offenses = db.Column(db.BigInteger)
    drug_abuse = db.Column(db.BigInteger)
    gambling = db.Column(db.BigInteger)
    against_family = db.Column(db.BigInteger)
    dui = db.Column(db.BigInteger)
    liquor_laws = db.Column(db.BigInteger)
    drunkenness = db.Column(db.BigInteger)
    disorderly_conduct = db.Column(db.BigInteger)
    vagrancy = db.Column(db.BigInteger)
    other = db.Column(db.BigInteger)
    suspicion = db.Column(db.BigInteger)
    curfew_loitering = db.Column(db.BigInteger)


class AgencySums(db.Model):

    __tablename__ = 'agency_sums_view'

    id = db.Column(db.BigInteger, autoincrement=True, primary_key=True)
    year = db.Column(db.SmallInteger)
    agency_id = db.Column(db.BigInteger)
    state_postal_abbr = db.Column(db.Text)
    ori = db.Column(db.Text)
    pub_agency_name = db.Column(db.Text)
    offense_id = db.Column(db.BigInteger) # reta_offense_subcat
    offense_subcat_id = db.Column(db.BigInteger)
    offense_code = db.Column(db.Text) # reta_offense
    offense_subcat_code = db.Column(db.Text)
    offense_subcat_name = db.Column(db.Text)
    offense_name = db.Column(db.Text)
    reported = db.Column(db.BigInteger)
    unfounded = db.Column(db.BigInteger)
    actual = db.Column(db.BigInteger)
    cleared = db.Column(db.BigInteger)
    juvenile_cleared = db.Column(db.BigInteger)

    def get(self, state = None, agency = None, year = None, county = None, explorer_offense = None):
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
        if explorer_offense:
            offense = ExplorerOffenseMapping(explorer_offense).reta_offense_code
            query = query.filter(AgencySums.offense_code == offense)

        query = query.join(AgencyParticipation, and_(AgencyParticipation.agency_id == AgencySums.agency_id, AgencyParticipation.year == AgencySums.year)).filter(AgencyParticipation.months_reported == 12)

        query = query.order_by(AgencySums.year.desc()) # Agency reported 12 Months.

        #print(query) # Dubug
        return query


class AgencyOffenseCounts(db.Model):
    __tablename__ = 'agency_offenses_view'

    id = db.Column(db.BigInteger, autoincrement=True, primary_key=True)
    year = db.Column(db.SmallInteger)
    agency_id = db.Column(db.BigInteger)
    state_postal_abbr = db.Column(db.Text)
    ori = db.Column(db.Text)
    pub_agency_name = db.Column(db.Text)
    offense_id = db.Column(db.BigInteger) # reta_offense_subcat
    offense_code = db.Column(db.Text) # reta_offense
    offense_name = db.Column(db.Text)
    reported = db.Column(db.BigInteger)
    unfounded = db.Column(db.BigInteger)
    actual = db.Column(db.BigInteger)
    cleared = db.Column(db.BigInteger)
    juvenile_cleared = db.Column(db.BigInteger)

    def get(self, state = None, agency = None, year = None, county = None, explorer_offense = None):
        """Get Agency Sums given a state/year/county/agency ori, etc."""
        query = AgencyOffenseCounts.query

        if state:
            query = query.filter(func.lower(AgencyOffenseCounts.state_postal_abbr) == state.lower())
        if county:
            subq = (db.session.query(models.RefAgencyCounty.agency_id)
                    .select_from(models.RefAgencyCounty)
                    .join(models.RefCounty, and_(models.RefAgencyCounty.county_id == models.RefCounty.county_id))
                    .filter(models.RefCounty.county_fips_code == county)
                )
            if year:
                subq = subq.filter(models.RefAgencyCounty.data_year == year)
            query = query.filter(AgencyOffenseCounts.agency_id.in_(subq.subquery()))
        if agency:
            query = query.filter(AgencyOffenseCounts.ori == agency)
        if year:
            query = query.filter(AgencyOffenseCounts.year == year)
        if explorer_offense:
            offense = ExplorerOffenseMapping(explorer_offense).reta_offense_code
            query = query.filter(AgencyOffenseCounts.offense_code == offense)

        query = query.join(AgencyParticipation,
                           and_(AgencyParticipation.agency_id == AgencyOffenseCounts.agency_id,
                                AgencyParticipation.year == AgencyOffenseCounts.year)).filter(AgencyParticipation.months_reported == 12)
        query = query.order_by(AgencyOffenseCounts.year.desc()) # Agency reported 12 Months.

        #print(query) # Dubug
        return query


class AgencyClassificationCounts(db.Model):
    __tablename__ = 'agency_classification_view'

    id = db.Column(db.BigInteger, autoincrement=True, primary_key=True)
    year = db.Column(db.SmallInteger)
    agency_id = db.Column(db.BigInteger)
    state_postal_abbr = db.Column(db.Text)
    ori = db.Column(db.Text)
    pub_agency_name = db.Column(db.Text)
    classification = db.Column(db.Text)
    reported = db.Column(db.BigInteger)
    unfounded = db.Column(db.BigInteger)
    actual = db.Column(db.BigInteger)
    cleared = db.Column(db.BigInteger)
    juvenile_cleared = db.Column(db.BigInteger)

    def get(self, state = None, agency = None, year = None, county = None, classification = None):
        """Get Agency Sums given a state/year/county/agency ori, etc."""
        query = AgencyClassificationCounts.query

        if state:
            query = query.filter(func.lower(AgencyClassificationCounts.state_postal_abbr) == state.lower())
        if county:
            subq = (db.session.query(models.RefAgencyCounty.agency_id)
                    .select_from(models.RefAgencyCounty)
                    .join(models.RefCounty, and_(models.RefAgencyCounty.county_id == models.RefCounty.county_id))
                    .filter(models.RefCounty.county_fips_code == county)
                )
            if year:
                subq = subq.filter(models.RefAgencyCounty.data_year == year)
            query = query.filter(AgencyClassificationCounts.agency_id.in_(subq.subquery()))
        if agency:
            query = query.filter(AgencyClassificationCounts.ori == agency)
        if year:
            query = query.filter(AgencyClassificationCounts.year == year)
        if classification:
            query = query.filter(func.lower(AgencyClassificationCounts.classification) == func.lower(classification))

        query = query.join(AgencyParticipation,
                           and_(AgencyParticipation.agency_id == AgencyClassificationCounts.agency_id,
                                AgencyParticipation.year == AgencyClassificationCounts.year)).filter(AgencyParticipation.months_reported == 12)
        query = query.order_by(AgencyClassificationCounts.year.desc()) # Agency reported 12 Months.

        #print(query) # Dubug
        return query


class CdeAgency(db.Model, FilterableModel):
    """A class for the denormalized cde_agencies table"""
    __tablename__ = 'cde_agencies'
    __table_args__ = (UniqueConstraint('agency_id'), )

    agency_id = db.Column(db.BigInteger, primary_key=True)
    ori = db.Column(db.String(9))
    legacy_ori = db.Column(db.String(9))
    agency_name = db.Column(db.Text)
    short_name = db.Column(db.Text)
    agency_type_id = db.Column(db.String(1))
    agency_type_name = db.Column(db.String(100))
    # FIXME: can add associations when we need them
    tribe_id = db.Column(db.BigInteger)
    campus_id = db.Column(db.BigInteger)
    city_id = db.Column(db.BigInteger)
    city_name = db.Column(db.Text)
    state_id = db.Column(db.SmallInteger)
    state_abbr = db.Column(db.String(2))
    primary_county_id = db.Column(db.BigInteger)
    primary_county = db.Column(db.Text)
    primary_county_fips = db.Column(db.String(5))
    agency_status = db.Column(db.String(1))
    submitting_agency_id = db.Column(db.BigInteger)
    submitting_sai = db.Column(db.String(9))
    submitting_name = db.Column(db.Text)
    submitting_state_abbr = db.Column(db.String(2))
    start_year = db.Column(db.SmallInteger)
    dormant_year = db.Column(db.SmallInteger)
    revised_rape_start = db.Column(db.SmallInteger)
    current_nibrs_start_year = db.Column(db.SmallInteger)
    current_year = db.Column(db.SmallInteger)
    population = db.Column(db.BigInteger)
    population_group_code = db.Column(db.String(2))
    population_group_desc = db.Column(db.Text)
    population_source_flag = db.Column(db.String(1))
    suburban_area_flag = db.Column(db.String(1))
    core_city_flag = db.Column(db.String(1))
    months_reported = db.Column(db.SmallInteger)
    nibrs_months_reported = db.Column(db.SmallInteger)
    past_10_years_reported = db.Column(db.SmallInteger)
    covered_by_id = db.Column(db.BigInteger)
    covered_by_ori = db.Column(db.String(9))
    covered_by_name = db.Column(db.Text)
    staffing_year = db.Column(db.SmallInteger)
    total_officers = db.Column(db.Integer)
    total_civilians = db.Column(db.Integer)
    icpsr_zip = db.Column(db.String(5))
    icpsr_lat = db.Column(db.Float)
    icpsr_lng = db.Column(db.Float)


class HtAgency(db.Model, FilterableModel):
    """Represents human trafficking counts reported by a single agency in a given year"""
    class Meta:
        __tablename__ = 'ht_agency'

    id = db.Column(db.Integer, primary_key=True)
    year = db.Column(db.SmallInteger)
    ori = db.Column(db.Text)
    agency_id = db.Column(db.BigInteger)
    agency_name = db.Column(db.Text)
    population = db.Column(db.BigInteger)
    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.Text)
    months_reported = db.Column(db.SmallInteger)
    sex_acts = db.Column(db.Integer)
    sex_acts_cleared = db.Column(db.Integer)
    sex_acts_juvenile_cleared = db.Column(db.Integer)
    servitude = db.Column(db.Integer)
    servitude_cleared = db.Column(db.Integer)
    servitude_juvenile_cleared = db.Column(db.Integer)


class HtSummary(db.Model):
    """Collects rollups of multiple HtAgency reports. You can use this
       table to get counts of human trafficking for a given agency, a
       specific state or national on a single or all years. Note that
       counts from US Territories are not available in this table (the
       FBI says they shouldn't be included."""
    class Meta:
        __tablename__ = 'ht_summary'

    ht_summary_id = db.Column(db.Integer, primary_key=True)
    grouping_bitmap = db.Column(db.Integer)
    year = db.Column(db.SmallInteger)
    ori = db.Column(db.Text)
    agency_id = db.Column(db.BigInteger)
    agency_name = db.Column(db.Text)
    agencies = db.Column(db.Integer)
    population = db.Column(db.BigInteger)
    state_id = db.Column(db.Integer)
    state_abbr = db.Column(db.Text)
    months_reported = db.Column(db.SmallInteger)
    sex_acts = db.Column(db.Integer)
    sex_acts_cleared = db.Column(db.Integer)
    sex_acts_juvenile_cleared = db.Column(db.Integer)
    servitude = db.Column(db.Integer)
    servitude_cleared = db.Column(db.Integer)
    servitude_juvenile_cleared = db.Column(db.Integer)

    @classmethod
    def grouped_by_state(cls, year=None, state_abbr=None):
        query = HtSummary.query

        query = query.filter(HtSummary.state_id != None)
        query = query.filter(HtSummary.agency_id == None)

        if year is not None:
            query = query.filter(HtSummary.year == year)

        if state_abbr is not None:
            query = query.filter(HtSummary.state_abbr == state_abbr)

        query = query.order_by(HtSummary.year, HtSummary.state_abbr)

        return query
