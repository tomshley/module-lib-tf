

### Terraform Deployment Instructions

#### Configure 

For your Terraform command line client to work with this Terraform repository, log in to the Terraform client.
Run the following command.

```shell
terraform login tware.jfrog.io
```

To resolve the Providers, add the following configuration to the ~/.terraformrc file.

```terraform
provider_installation {
    direct {
        exclude = ["registry.terraform.io/*/*"]
    }
    network_mirror {
        url = "https://tware.jfrog.io/artifactory/api/terraform/hexagonal-provisioning/providers/"
    }
}
```

#### Deploy

To deploy a Terraform module into an Artifactory repository, use the following cURL command with the relevant path parameters.
The required parameters are namespace, module-name, provider-name (system) and version as follows.

```shell
curl -uasktom@tware.email:<PASSWORD> -XPUT "https://tware.jfrog.io/artifactory/hexagonal-provisioning/<NAMESPACE>/<MODULE-NAME>/<PROVIDER-NAME>/<VERSION>.zip" -T <PATH_TO_FILE>
```

To deploy a Terraform provider into an Artifactory repository, use the following cURL command with the relevant path parameters.
The required parameters are namespace, provider-name (system), version, operating-system (os) and architecture (arch) as follows.

```shell
curl -uasktom@tware.email:<PASSWORD> -XPUT "https://tware.jfrog.io/artifactory/hexagonal-provisioning/<NAMESPACE>/<PROVIDER-NAME>/<VERSION>/terraform-provider-<PROVIDER-NAME>_<VERSION>_<OS>_<ARCH>.zip" -T <PATH_TO_FILE>
```

#### Resolve

To resolve a Terraform module from Artifactory, simply configure the module in your HCL file (.tf) as follows.

```terraform
module "module-name" {
    source  = "tware.jfrog.io/hexagonal-provisioning__namespace/module-name/provider(system)"
}
```

To resolve a Terraform provider from Artifactory, simply configure the provider in your HCL file (.tf) as follows.

```terraform
terraform {
    required_providers {
        provider-name = {
            source = "namespace/provider-name"
        }
    }
}
```

