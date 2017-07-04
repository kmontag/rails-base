**rails-base**


To initialize:

* Remove distribution lines from `.gitignore`

```bash
make deps
./rails new -d postgresql [options] .
./rake db:migrate
```

To start the server:

```bash
make up
```

To run standard Rails/Rake commands:

```bash
./rake db:migrate
./rails generate migration AddFooToBars
```

To set up infrastructure:

* Add AWS credentials to `terraform/credentials`
* Copy deploy key to `terraform/deploy.id_rsa`
* Customize infrastructure variables in `terraform/terraform.tfvars`

```bash
cd terraform/
terraform get
terraform apply
```

To deploy:

* Create a user in the `deployers` group on IAM and add your public
  key
* Set application name and repo variables in `config/deploy.rb`

```bash
ssh-add /path/to/iam/key
bundle install --gemfile=Gemfile.deploy
BUNDLE_GEMFILE=Gemfile.deploy bundle exec cap production deploy
```

To log in to the server:

```bash
ssh-add /path/to/iam/key
ssh deploy@$(cd terraform ; terraform output instance_address)
```

To open in browser:

```bash
open $(cd terraform ; terraform output web_address)
```
