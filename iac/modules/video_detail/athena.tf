resource "aws_athena_workgroup" "main" {
  name = local.ns
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    result_configuration {
      output_location = "s3://${var.raw_target_bucket_id}/output/"
    }
  }
  tags = var.tags
}

resource "aws_glue_catalog_database" "main" {
  name = local.ns
}

resource "aws_glue_catalog_table" "registration" {
  name          = "registration"
  database_name = aws_glue_catalog_database.main.name
  table_type    = "EXTERNAL_TABLE"
  storage_descriptor {
    location      = "s3://${var.raw_target_bucket_id}/main"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = local.ns
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "wmukid"
      type = "string"
    }

    columns {
      name = "cdpid"
      type = "string"
    }

    columns {
      name = "assetname"
      type = "string"
    }

    columns {
      name = "authrequired"
      type = "string"
    }

    columns {
      name = "channel"
      type = "string"
    }

    columns {
      name = "contenttype"
      type = "string"
    }

    columns {
      name = "eventname"
      type = "string"
    }

    columns {
      name = "freeview"
      type = "string"
    }

    columns {
      name = "highlander_id"
      type = "string"
    }

    columns {
      name = "islive"
      type = "string"
    }

    columns {
      name = "kruxid"
      type = "string"
    }

    columns {
      name = "mediaid"
      type = "string"
    }

    columns {
      name = "playername"
      type = "string"
    }

    columns {
      name = "seasonepisode"
      type = "string"
    }

    columns {
      name = "seriesname"
      type = "string"
    }

    columns {
      name = "seriestitleid"
      type = "string"
    }

    columns {
      name = "showtype"
      type = "string"
    }

    columns {
      name = "site"
      type = "string"
    }

    columns {
      name = "subtitle"
      type = "string"
    }

    columns {
      name = "title"
      type = "string"
    }

    columns {
      name = "videotitleid"
      type = "string"
    }

    columns {
      name = "viewerauthstate"
      type = "string"
    }

    columns {
      name = "sessionid"
      type = "string"
    }

    columns {
      name = "sourceipaddress"
      type = "string"
    }

    columns {
      name = "eventtime"
      type = "string"
    }

    columns {
      name = "receivedattimestamp"
      type = "timestamp"
    }

    columns {
      name = "receivedattimestampstring"
      type = "string"
    }
  }
}
