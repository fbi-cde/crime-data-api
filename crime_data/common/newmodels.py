"""Models for tables not included in UCR, generated for our system

`models.py` is meant to simply reflect the tables as they exist in UCR
itself; `cdemodels.py` extends those model classes.  *These* models, on
the other hand, must actually be generated in our system.
"""
from copy import deepcopy
import logging
from psycopg2 import ProgrammingError
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import backref
from sqlalchemy.sql.elements import BinaryExpression
from sqlalchemy import func
from sqlalchemy.sql import sqltypes
from flask_restful import abort

from crime_data.common import models
from crime_data.extensions import db
from sqlalchemy import or_

class ParticipationRate(db.Model):
    __tablename__ = 'cde_participation_rates'

    data_year = db.Column(db.SmallInteger, nullable=False, primary_key=True)
    total_population = db.Column(db.BigInteger)
    covered_population = db.Column(db.BigInteger)
    total_agencies = db.Column(db.Integer)
    reporting_agencies = db.Column(db.Integer)
    reporting_rate = db.Column(db.Float)
    state_id = db.Column(db.Integer)
    county_id = db.Column(db.Integer)


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
