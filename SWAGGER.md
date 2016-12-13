# Swagger

To make it easier to see what the APIs can do, this project includes
endpoints the return [Swagger](http://swagger.io/) documentation for
the API. These documents are not yet complete or consistent and can
not yet be used to automatically generate API clients or to validate
API responses. But they do let you test out the API and see roughly
what the valid behavior is.

## Initial Setup

Currently, both endpoints must be secured behind HTTP Authentication
to deter unauthorized access. To use these endpoints locally, you can
try the following commands in your shell.

``` shell
export HTTP_USERNAME=username
export HTTP_PASSWORD=password
```

Similarly, to use these endpoints on CloudFoundry, you can do one of
two things. One option is to set the values for `HTTP_BASIC_USERNAME`
or `HTTP_BASIC_PASSWORD` in the
`VCAP_SERVICES.user-services.credentials` sections. Alternatively, you
can explicitly define environment variables if those aren't available.


``` shell
cf set-env crime-data-api HTTP_USERNAME username
cf set-env crime-date-api HTTP_PASSWORD password
cf restage crime-data-api
```

The HTTP authentication is mandatory while the application is being
developed. You can't bypass it by setting the username or password to
blanks. Also, maybe try something different for both of them and limit
distribution only to authorized personnel.

## Swagger Endpoints

The [/swagger/](https://crime-data-api.fr.cloud.gov/swagger/) returns
a dynamically generated `swagger.json` file with a listing of all the
endpoints and their parameters.

The [/swagger-ui/](https://crime-data-api.fr.cloud.gov/swagger-ui/)
path returns the Swagger-UI, an interactive view of the endpoints that
lets you see input parameters, output formats and even lets you run
queries against the API.

## Adding a New Method

We are using
the [flask-apispec](https://github.com/jmcarp/flask-apispec) library
for generating the Swagger documentation and UI. This is a convenient
mechanism that lets us document our endpoints with only decorators:

``` python
import flask_apispec as swagger

class IncidentsList(CdeResource):

    schema = marshmallow_schemas.NibrsIncidentSchema(many=True)
    tables = cdemodels.IncidentTableFamily()
    # Enable fast counting.
    fast_count = True

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @swagger.doc(tags=['incidents'],
                 description=('Return all matching incidents. Queries can drill down '
                              'on specific values for fields within the incidents record.')
    )
    @swagger.use_kwargs(marshmallow_schemas.ArgumentsSchema, apply=False, locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.IncidentsListResponseSchema, apply=False)
    @tuning_page
    def get(self, args):
        return self._get(args)

```

The flask-apispec library is meant to be used for RESTful
applications, and by default its decorators define the allowed schema
for parsing or returning arguments in addition to documenting those
schema within Swagger. The Crime Data API is not RESTful and many API
methods allow the user to specify additional fields as part of the
request (ie, `/incidents/?victim.age_num=24`) or might return
additional fields (ie, when you use the `by` parameter to group
counts, each count result will include the fields being grouped
by). We use the `apply=False` argument with flask-apispec decorators
to tell it that we only want to describe the endpoint with APISpec;
otherwise it will use the supplied Marshmallow schemas to
parse/serialize responses and discard any additional fields.

If you are adding a new endpoint, there are three decorators that can
be applied to functions.


``` python
@swagger.doc(tags=['incidents'],
             description=('Return all matching incidents. Queries can drill down '
                          'on specific values for fields within the incidents record.')
)
@swagger.use_kwargs(marshmallow_schemas.ArgumentsSchema, apply=False, locations=['query'])
@swagger.marshal_with(marshmallow_schemas.IncidentsListResponseSchema, apply=False)
```

The `@doc` decorator allows you to specify a description for the API
in Markdown. Tags are used to group together related API endpoints (if
you tag an API with multiple tags, it will show up in several places
in the Swagger UI).

The `@use_kwargs` decorator is used to specify what arguments the API
method takes. It takes either a dict of fields or a Marshmallow schema
like those we are using already. This could normally be used for
webargs processing, but we already are using the `@use_args` decorator
from webargs, and flask-apispec currently only has support for
translating input parameters to kwargs (which makes sense in a RESTful
API, but not for one that supports arbitrary queries). So we tell
flask-apispec to only use this information for documentation with the
`apply=False` argument and we use the `locations=['query']` argument
to specify that parameters are only specified as query parameters on
the URL.

The `@marshal_with` decorator tells `flask-apispec` what the return
type of the API method will be. It takes a Marshmallow schema as its
type. As before, we send it the `apply=False` argument to limit its
functionality specifically to documenting the returned type in
Swagger. Since many of our response return their data in a paginated
structure like

``` json
{
  "pagination": {...}
  "results": [{...}, {...} ...]
}
```

it might be necessary to define a Marshmallow schema for the response
that inherits from a basic response schema that captures the paginated
structure. For instance, the `IncidentsListResponseSchema` specified above looks like

``` python
class IncidentsListResponseSchema(PaginatedResponseSchema):
    results = ma.Nested(NibrsIncidentSchema, many=True)
```

Of course, since we are only using flask-apispec for generating the
documentation, it won't cause the program to crash if you specify an
incorrect or incomplete schema. But it's better to be more specific
about what it returns.

## Missing Pieces

There are some rough edges, but this has been the fastest way to get a
Swagger UI that tracks the actual functionality of our application as
we develop it. This is still not a complete Swagger specification
though, and we will need to fix the following issues eventually should
we decide to make the Swagger JSON public for outside developers to use:

* Figure out the best ways to represent the allowed but optional query
  parameters for most endpoints within the Swagger API. Since there
  are hundreds of these, they may overwhelm the interface. In
  addition, figuring out these parameters involves a DB query with an
  app context that may not be easily accommodated within a decorator.
* The output schema is currently generated by traversing Marshmallow
  schemas. Figure out if there is a better way to embed documentation
  in the Marshmallow Field type that can be passed along to
  Swagger. In addition, figure out if we can declare that the
  Marshmallow schema might include additional fields.
* It seems a bit redundant to have both `flask-restful` and
  `flask-apispec` on the project. If we could create a `@use_args`
  decorator for `flask-apispec` that might be enough to remove one of
  these libraries.

None of this remaining work is particularly urgent, and it might be
something that we just decide to avoid altogether, since both
`flask-apispec` and `Swagger` itself are meant to be used for RESTful
APIs and the Crime Data API most certainly is not.
