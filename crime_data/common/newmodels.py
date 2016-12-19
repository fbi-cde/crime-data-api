"""Models for tables not included in UCR, generated for our system

`models.py` is meant to simply reflect the tables as they exist in UCR
itself; `cdemodels.py` extends those model classes.  *These* models, on
the other hand, must actually be generated in our system.
"""
import logging
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
