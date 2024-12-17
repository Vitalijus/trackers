# Trackers

![Version](https://img.shields.io/badge/dynamic/json?color=blue&label=version&prefix=v&query=%24.version&url=https%3A%2F%2Fe49ee07a33e40aab8c7c4b39816a12eb6734f2f0%40raw.githubusercontent.com%2FAutorama%2Fcustomers%2Fdevelop%2Fpackage.json)
![License](https://img.shields.io/badge/dynamic/json?color=888&label=license&query=%24.license&url=https%3A%2F%2Fe49ee07a33e40aab8c7c4b39816a12eb6734f2f0%40raw.githubusercontent.com%2FAutorama%2Fcustomers%2Fdevelop%2Fpackage.json)

Rails app to store Teltonika telematics data.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

## Prerequisites

- Install [Ruby](https://www.ruby-lang.org/en/downloads/).
- Install [Postgres](https://www.postgresql.org/).
- Install [Docker](https://www.docker.com/).
- Install [Teltonika Configurator][https://wiki.teltonika-gps.com/view/Teltonika_Configurator_versions](https://wiki.teltonika-gps.com/view/Teltonika_Configurator_versions).
- Clone [trackers](https://github.com/Vitalijus/trackers).

## Setup Teltonika Configurator

Teltonika Configurator is a program to configure modules. Below is an example for FMT100 module.

An example of GPRS settings:
- APN name: iot.truphone.com
- domain: 52.12.75.4 (AWS Public IP)
- port:65432 (AWS Security group PORT)

### How it works?

Teltonika module (e.g. FMT100) communicating with the AWS server. On first communication step module is authenticated by IMEI,
second time data from module decoded and confirmation about number_of_rec is sent back to the module.
Positive response is sent to the server, if decoded num_of_rec matching with what
module has send, then communication is over. Otherwise if decoded num_of_rec not matching with module's, then module will send data again. Module is sending data packets every 2min. When num_of_rec is matching, then module data, like latitude, longitude, speed is being saved to the DB.

- Teltonika Telematics: [https://teltonika-gps.com/](https://teltonika-gps.com/).
- FMT100 module: [https://teltonika-gps.com/products/trackers/fmt100](https://teltonika-gps.com/products/trackers/fmt100).
- Codec: [https://wiki.teltonika-gps.com/view/Codec](https://wiki.teltonika-gps.com/view/Codec).

## Installing

Pull the application code from the github repo.

```sh
git clone git@github.com:Autorama/Customers.git Customers
```

Change into the application directory.

```sh
cd Customers
```

Install dependencies

```sh
bundle install
```

## Running the application

The app needs a dockerised set of service (E.g.: Postgres, Redis, ElasticSearch)
to run.

Please refer to
[grid-shared-dev-services](https://github.com/Autorama/grid-shared-dev-services)
to setup the container.

Command below will create database, run migration, and start foreman:

```sh
./dev.sh
```

### Visit

- Running app: [http://localhost:3302/](http://localhost:3302/).
- Sidekiq: [http://localhost:3302/sidekiq/](http://localhost:3302/sidekiq).
- GQL Playground:
  [http://localhost:3302/graphiql/](http://localhost:3302/graphiql).

## ElasticSearch

Push data to the index:

```
docker-compose exec web rake searchkick:reindex CLASS=<MODEL NAME>
```

## Running the tests

Testing is implemented using

- rspec-rails
- rspec-graphql_matchers
- shoulda-matchers
- shoulda-callbacks-matchers
- factory_bot_rails
- simplecov

To run the whole test suite

```sh
bundle exec rspec
```

To run an individual spec

```sh
bundle exec rspec spec/path/to/test
```

To run full spec with junit formatted output (per-CI):

```sh
bundle exec rspec --format RspecJunitFormatter \
    --out results.xml --format progress --format documentation
```

## Useful commands

### Rails Console

```sh
rails c
```

### Soft delete

Currently, there is no UI for deleting an object on a customer's app. Therefore, any deletions need to be done carefully in rails console.

For soft delete, we use [acts_as_paranoid](https://github.com/ActsAsParanoid/acts_as_paranoid) gem that will set the `deleted_at` datetime field on the table. The deleted record will not be available in normal queries.

- Find the person or company: `person = Person.find(1)`
- Get the party of the above object: `party = person.party`
- Destroy as usual: `party.destroy`

This will perform soft delete on main object and associations.

### Reinitiate Database

```sh
rake db:drop db:create db:migrate db:seed
```

## Built With

- [Docker](https://www.docker.com/) - PaaS.
- [Postgres](https://www.postgresql.org/) - Open source database.
- [GraphQL Ruby](https://graphql-ruby.org/) - Ruby implementation of GraphQL.

## Authors

- **Vitalijus Desukas** - _Lead engineer_ -
  [Vitalijus](https://github.com/Vitalijus)

## Main technologies

<img alt="Rails" src="https://img.shields.io/badge/rails-%23CC0000.svg?style=for-the-badge&logo=ruby-on-rails&logoColor=white"/> <img alt="Postgres" src ="https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white"/> <img alt="GraphQL" src="https://img.shields.io/badge/-GraphQL-E10098?style=for-the-badge&logo=graphql&logoColor=white"/>




# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
