"""Models for tables not included in UCR, generated for our system

`models.py` is meant to simply reflect the tables as they exist in UCR
itself; `cdemodels.py` extends those model classes.  *These* models, on
the other hand, must actually be generated in our system.
"""
from psycopg2 import ProgrammingError
from sqlalchemy.dialects.postgresql import JSON
from sqlalchemy.orm import backref

from crime_data.common import models
from crime_data.extensions import db


class NibrsIncidentRepresentation(db.Model):
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
    def create(cls):
        """Creates and populates this table in the database."""
        try:
            cls.__table__.create(db.session.bind)
        except ProgrammingError:
            pass
        cls.fill()

    @classmethod
    def fill(cls):
        """Generates and caches output for all NibrsIncidents."""

        for incident in models.NibrsIncident.query:
            if not incident.representation:
                incident.representation = cls(incident=incident)
            incident.representation.generate()
        models.NibrsIncident.query.session.commit()

    def generate(self):
        """Generates and caches output for a single NibrsIncident."""

        from crime_data.common import marshmallow_schemas
        _schema = marshmallow_schemas.NibrsIncidentSchema()
        self.representation = _schema.dump(self.incident).data
