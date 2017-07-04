** rails-base

To initialize:

* Remove distribution lines from `.gitignore`

    make deps
    ./rails new -d postgresql [options] .
    ./rake db:migrate

To start the server:

    make up

To run standard Rails/Rake commands:

    ./rake db:migrate
    ./rails generate migration AddFooToBars
    
To set up infrastructure:

* Add AWS credentials to `terraform/credentials`
* Copy deploy key to `terraform/deploy.id_rsa`
* Customize infrastructure variables in `terraform/terraform.tfvars`

    cd terraform/
    terraform get
    terraform apply
        
To deploy:

* Create a user in the `deployers` group on IAM and add your public
  key
* Set application name and repo variables in `config/deploy.rb`

    ssh-add /path/to/iam/key
    bundle install --gemfile=Gemfile.deploy
    BUNDLE_GEMFILE=Gemfile.deploy bundle exec cap production deploy
    
To log in to the server:
    
    ssh-add /path/to/iam/key
    ssh deploy@$(cd terraform ; terraform output instance_address)
