To start the server:

    make up

To run standard Rails/Rake commands:

    ./rake db:migrate
    ./rails generate migration AddFooToBars
    
To see all available commands:

    make help

To deploy infrastructure:

    cd terraform
    terraform plan
    terraform apply

To deploy the application:

    cap production deploy

To SSH:

    ssh deploy@$(cd terraform && terraform output ssh_host)

To view:

    open https://$(cd terraform && terraform output web_host)
