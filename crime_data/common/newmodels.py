"""Models for tables not included in UCR, generated for our system

`models.py` is meant to simply reflect the tables as they exist in UCR
itself; `cdemodels.py` extends those model classes.  *These* models, on
the other hand, must actually be generated in our system.
"""
from flask_restful import abort
from sqlalchemy import and_, func, or_
from sqlalchemy.exc import ArgumentError
from sqlalchemy.orm import aliased, backref
from sqlalchemy.sql import label
from sqlalchemy.sql import sqltypes as st

from crime_data.common import models, cdemodels
from crime_data.extensions import db
from sqlalchemy.dialects.postgresql import JSON
from psycopg2 import ProgrammingError

session = db.session


class NibrsIncidentRepresentation(db.Model):
    __tablename__ = 'nibrs_incident_representation'

    incident_representation_id = db.Column(db.BigInteger, primary_key=True)
    incident_id = db.Column(db.BigInteger, db.ForeignKey(models.NibrsIncident.incident_id))
    representation = db.Column(db.Text)
    incident = db.relationship(models.NibrsIncident, uselist=False, backref=backref('representation', uselist=False))

    @classmethod
    def create(cls):
        try:
            cls.__table__.create(db.session.bind)
        except ProgrammingError:
            pass
        cls.fill()

    @classmethod
    def fill(cls):
        for incident in models.NibrsIncident.query:
            if not incident.representation:
                incident.representation = cls(incident=incident)
                incident.representation.regenerate()
        models.NibrsIncident.query.session.commit()

    def regenerate(self):
        from crime_data.common import marshmallow_schemas
        _schema = marshmallow_schemas.NibrsIncidentSchema()
        result = self._schema.dumps(self.incident)
        self.representation = self._schema.dumps(self.incident).data
