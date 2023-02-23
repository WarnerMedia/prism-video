# late_s3_metrics

This function receives an event when a s3 object is dropped.  It opens the object reads thru the rows in the object to get a count then updates a custom cloudwatch metric.
