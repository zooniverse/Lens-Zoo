# SpaceWarps

## Setting up
    
    git clone git@github.com:zooniverse/Lens-Zoo.git
    npm install .
    
## Starting local server

    hem server --includeCss

## Building subjects

    cd /path/to/ouroboros
    rails r /path/to/spacewarps/data-import/builder.rb

or to build against staging server

    RAILS_ENV=staging rails r /path/to/spacewarps/data-import/builder.rb
    ssh ubuntu@dev.zooniverse.org
    cd /rails/apps/ouroboros_staging/current
    sudo -u www-data bundle exec rails c staging
    
    # Clear the redis cache
    SpacewarpSubject.redis_set.destroy
    
    # Activate subjects
    SpacewarpSubject.activate_randomly

## Building and deploying project

    ./build.rb
