# App Service Landing Zone Accelerator - ARM Template Usage

When we developed this Landing Zone Accelerator, we chose Bicep as our first Infrastructure as Code deployment method due to its many advantages. We were excited about trying a new IaC experience and drawn to its declarative nature and ease to onboard compared to ARM templates. Another benefit that we recognized was the capability to generate ARM templates from a Bicep template, which we leverage as part of our GitHub workflow. 

ARM is not recommended for customers to new to IaC, we suggest using Bicep as a IaC language. Even if you have already invested in ARM, mixing with Bicep is totally fine, if you still want to use the ARM template version, this document will explain how to generate and use the ARM template version of this Landing Zone Accelerator.

## Understanding Bicep to ARM conversion
Bicep is a domain-specific language (DSL) that uses declarative syntax to deploy Azure resources. In a Bicep file, you define the infrastructure you want to deploy to Azure, and then use that file throughout the development lifecycle to repeatedly deploy your infrastructure.

You can use Bicep instead of JSON to develop your Azure Resource Manager templates (ARM templates). The JSON syntax to create an ARM template can be verbose and require complicated expressions. Bicep syntax reduces that complexity and improves the development experience. Bicep is a transparent abstraction over ARM template JSON and doesn't lose any of the JSON template capabilities. During deployment, the Bicep CLI converts a Bicep file into ARM template JSON.

For more information please see [this](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

## How to convert Bicep To ARM using Automation
Initially we had prepared automated way, so for the GitHub Actions you can use this snippet

```yaml
  Generate-ARM:
    name: "Generate ARM Template"
    needs: build-and-deploy
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the code
        uses: actions/checkout@v2

      # Exporting ARM template from the bicep file
      - name: Export ARM template
        working-directory: ./reference-implementations/LOB-ILB-ASEv3/bicep
        run : |
          az bicep build --file main.bicep --outfile ../azure-resource-manager/ase-arm.json
      # Uploading exported ARM template to GitHub's artifact 
      - name: Archive code coverage results
        uses: actions/upload-artifact@v2
        with:
          name: ase-arm
          path: /reference-implementations/LOB-ILB-ASEv3/azure-resource-manager/ase-arm.json
          retention-days: 2

      # Committing and pushing exported ARM template to the same repo.
      - name: Commit changes
        uses: EndBug/add-and-commit@v7
        with:
          author_name: APIM-Action
          author_email: <enter your email in here>
          message: 'ARM template updated'
          cwd: '/reference-implementations/LOB-ILB-ASEv3/azure-resource-manager/'
          branch_mode: create
          branch: 'arm-${{github.run_number}}'
          add: 'ase-arm.json' 
```

What this snippet will do is step by step
- Check out the latest code
- Export the ARM template from main.bicep file
- Put it in GitHub artifactory
- And using a thirtd party Action commit that newly generated ARM template to a newly created branch.

You can use the similar steps for Azure DevOps, if you don't want to commit to a new Branch you can remove the last step.

## How to convert Bicep To ARM using CLI 
Converting Bicep file to ARM template is a simple command

```console
az bicep build --file main.bicep --outfile ../azure-resource-manager/ase-arm.json
```

## Generated ARM template validation.

During our deployment, we added several Bicep validation / preflight checks as seen in our [Action yaml file](/.github/workflows/es-ase.yml). If those validations pass without errors, we continue to deploy the Bicep template. If Bicep deploys without any error, that version is a good candidate to generate the ARM template.

There are several ways to **Validate** an ARM Template;

- Syntax: Code

- Behavior: What is the code doing that you may want to be aware of? Are you handling secure parameters (e.g. secrets) correctly? Is the use of location for resources reasonable? Do you have practices that may cause problems across environments (subs, clouds, etc.)?

- Result: What does the code do (deploy) or not that you may want to be aware of? (no NSGs or NSGs too permissive, password vs key authentication)

- Intent: Does the code do what it is intended to do?

- Success: Does the code successfully deploy?

**Syntax**: For syntax check ```bicep build``` completes that validation.

**Behavior**: Bicep completes most of behavior checks, while [arm-ttk](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/test-toolkit) has some additional capabilities that will eventually be incorporated into Bicep or other tools. 

**Result**: This can be covered using [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview). 

**Intent**: We can run what-if scenarios on the ARM Template. This, however, requires human interaction and thus cannot be automated. 

**Success**: Since before ARM Template, Bicep template finished successfully (otherwise ARM Template generation step would not start) so we are sure that ARM Template will work, so no need to add any validation on that. This doesn't guarantee a successful deployment as there may be other factors such as region availability, user permission, policy conflict that could lead to a failed deployment even if the ARM template is completely valid. 

As a result, since the ARM Template is generated from the Bicep template, additional steps to **validate the ARM Template** are negligible.
