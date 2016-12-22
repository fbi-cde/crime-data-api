"""Models for tables not included in UCR, generated for our system

`models.py` is meant to simply reflect the tables as they exist in UCR
itself; `cdemodels.py` extends those model classes.  *These* models, on
the other hand, must actually be generated in our system.
"""
from copy import deepcopy
import logging
from psycopg2 import ProgrammingError
from sqlalchemy.dialects.postgresql import JSON
from sqlalchemy.orm import backref

from crime_data.common import models, newmodels
from crime_data.extensions import db
from sqlalchemy import or_

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
    representation = db.Column(JSON)
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
            qry = models.NibrsIncident.query.filter(models.NibrsIncident.representation == None).limit(batch_size)
            for incident in qry:
                finished = False  # until the query comes back empty
                incident.representation = cls(incident=incident)
                incident.representation.generate()
            models.NibrsIncident.query.session.commit()
            logging.warning("Batch #{batch_no} of #{batch_size} complete".format(batch_no=batch_no, batch_size=batch_size))
            batch_no += 1

    def generate(self):
        """Generates and caches output for a single NibrsIncident."""

        from crime_data.common import marshmallow_schemas
        _schema = marshmallow_schemas.NibrsIncidentSchema()
        self.representation = _schema.dump(self.incident).data

class RetaMonthOffenseSubcatSummary(db.Model, CreatableModel):

    __tablename__ = 'reta_month_offense_subcat_summary'

    sql = """
    SELECT SUM(rmos.reported_count) AS reported,
           SUM(rmos.unfounded_count) AS unfounded,
           SUM(rmos.actual_count) AS actual,
           SUM(rmos.cleared_count) AS cleared,
           SUM(rmos.juvenile_cleared_count) AS juvenile_cleared,
           rm.data_year,
           rm.month_num,
           ros.offense_subcat_name,
           ros.offense_subcat_code,
           ro.offense_name,
           ro.offense_code,
           roc.offense_category_name,
           oc.classification_name,
           ra.ori,
           ra.ucr_agency_name,
           ra.ncic_agency_name,
           rc.city_name,
           rs.state_name,
           rs.state_abbr,
           rpf.population_family_name,
           rpf.population_family_desc
    FROM   reta_month_offense_subcat rmos
    JOIN   reta_offense_subcat ros ON (ros.offense_subcat_id = rmos.offense_subcat_id)
    JOIN   reta_offense ro ON (ro.offense_id = ros.offense_id)
    JOIN   reta_offense_category roc ON (roc.offense_category_id = ro.offense_category_id)
    JOIN   offense_classification oc ON (oc.classification_id = ro.classification_id)
    JOIN   reta_month rm ON (rmos.reta_month_id = rm.reta_month_id)
    JOIN   ref_agency ra ON (rm.agency_id = ra.agency_id)
    JOIN   ref_city rc ON (ra.city_id = rc.city_id)
    JOIN   ref_state rs ON (ra.state_id = rs.state_id)
    JOIN   ref_population_family rpf ON (ra.population_family_id = rpf.population_family_id)
    GROUP BY CUBE (data_year, month_num,
                   (offense_subcat_name, offense_subcat_code),
                   (offense_name, offense_code),
                   offense_category_name,
                   classification_name,
                   (ori, ucr_agency_name, ncic_agency_name),
                   city_name, (state_name, state_abbr),
                   (population_family_name, population_family_desc)
                   )
    ORDER BY ucr_agency_name, data_year, month_num
    """

    inserter = """INSERT INTO {}
        (reported, unfounded, actual, cleared, juvenile_cleared,
         data_year, month_num,
         offense_subcat_name, offense_subcat_code,
         offense_name, offense_code, offense_category_name,
         classification_name,
         ori, ucr_agency_name, ncic_agency_name,
         city_name, state_name, state_abbr,
         population_family_name, population_family_desc)
        {}""".format(__tablename__, sql)

    grouping_sets = {'data_year': [], 'month_num': [],
        'offense_subcat_name': ['offense_subcat_code'],
        'offense_subcat_code': ['offense_subcat_name'],
        'offense_name': ['offense_code'],
        'offense_code': ['offense_name'],
        'offense_category_name': [],
        'classification_name': [],
        'ori': ['ucr_agency_name', 'ncic_agency_name'],
        'ucr_agency_name': ['ori', 'ncic_agency_name'],
        'ncic_agency_name': ['ori', 'ucr_agency_name'],
        'city_name': [],
        'state_name': ['state_abbr'],
        'state_abbr': ['state_name'],
        'population_family_name': ['population_family_desc'],
        'population_family_desc': ['population_family_name'],
        }

    @classmethod
    def regenerate(cls):
        """Generates or replaces all cached records."""

        cls.query.delete()
        db.session.execute(cls.inserter)
        db.session.commit()
        cls.query.filter(cls.reported == 0).filter(cls.unfounded == 0). \
            filter(cls.actual == 0).filter(cls.cleared == 0). \
            filter(cls.juvenile_cleared == 0).delete()
        db.session.commit()

    id = db.Column(db.BigInteger, autoincrement=True, primary_key=True)
    reported = db.Column(db.BigInteger)
    unfounded = db.Column(db.BigInteger)
    actual = db.Column(db.BigInteger)
    cleared = db.Column(db.BigInteger)
    juvenile_cleared = db.Column(db.BigInteger)
    data_year = db.Column(db.SmallInteger)
    month_num = db.Column(db.SmallInteger)
    offense_subcat_name = db.Column(db.Text)
    offense_subcat_code = db.Column(db.Text)
    offense_name = db.Column(db.Text)
    offense_code = db.Column(db.Text)
    offense_category_name = db.Column(db.Text)
    classification_name = db.Column(db.Text)
    ori = db.Column(db.Text)
    ucr_agency_name = db.Column(db.Text)
    ncic_agency_name = db.Column(db.Text)
    city_name = db.Column(db.Text)
    state_name = db.Column(db.Text)
    state_abbr = db.Column(db.Text)
    population_family_name = db.Column(db.Text)
    population_family_desc = db.Column(db.Text)

    @classmethod
    def add_groupings_to_filters(cls, filters, group_by_column_names):
        "Convert `by` arguments to `where not null` filters"
        for group_column in group_by_column_names:
            if group_column not in [f[0] for f in filters]:
                filters.append((group_column, '__ne__', [None, ]))
                for sibling_col in cls.grouping_sets[group_column]:
                    if sibling_col not in [f[0] for f in filters]:
                        filters.append((sibling_col, '__ne__', [None, ]))
        return filters

    @classmethod
    def filtered(cls, filters):
        qry = cls.query
        unfiltered = deepcopy(cls.grouping_sets)
        for (col_name, comparitor, values) in filters:
            unfiltered.pop(col_name)
            col = getattr(cls, col_name)
            operation = getattr(col, comparitor)
            qry = qry.filter(or_(operation(v) for v in values)).order_by(col)
        for col_name in unfiltered:
            col = getattr(cls, col_name)
            qry = qry.filter(col == None)
        return qry
