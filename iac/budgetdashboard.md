# Budget Dashboards(should be revised / reviewed monthly)

## How do we collect our costs?

- We tag all resources in our terraform code so we leverage the application and environment tags to determine resource costs.

## How do we know if we have gone over budget?

- We have alerts setup that get emailed via SNS when 100% of the budget has been reached. We could adjust the percentage to avoid surprises.
