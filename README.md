# terraform-jenkins

Create a Jenkins master and a slave on Google Cloud

## Requirement
- Terraform is installed and included in path.

## Setup

```
terraform init
```
Run the above command only once.

## Run

Place the Google Cloud [authentication JSON file](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file) in the project root folder and rename it to `account.json`.

Run the following command.
```
terraform apply
```

Provide the ID of the Google Cloud project (`project_id`) when prompted.

## Example Output
```
jenkins_ip = 35.197.134.186
jenkins_password = password
```

- `jenkins_ip` indicates the public IP address of the Jenkins master.
- `jenkins_password` is the admin password for Jenkins.

Browse `http://<jenkins_ip>:8080` to access the Jenkins web UI. Use the following details to authenticate:
```
username: admin
password: <jenkins_password>
```

If the environment is no longer needed,
```
terraform destroy
```

## Configuration
- The default admin password for Jenkins can be modified in `main.tf`.
- The default value for `project_id` can be provided in `main.tf`.