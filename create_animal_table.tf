provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  version = "~> 1.17"

}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
  version = "~> 1.17"

}



resource "aws_dynamodb_table" "us-east-1" {
  provider = "aws.us-east-1"

  hash_key         = "AnimalType"
  range_key        = "AnimalName"  
  name             = "Animal"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity    = 5
  write_capacity   = 5

  server_side_encryption {                                         #Enable serverside encryption 
   enabled = true

   }
    point_in_time_recovery {                                       #Enable Point in time recovery 
   enabled = true

   }
  attribute {
    name = "AnimalType"
    type = "S"
  }
    attribute {
    name = "AnimalName"
    type = "S"
  }
  attribute {
    name = "Owner"
    type = "S"
  }
  attribute {
    name = "Breed"
    type = "S"
  }

    global_secondary_index {                                          #Gloabl Sencodary index 
    name               = "OwnerIndec"
    hash_key           = "Owner"
    range_key          = "Breed"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
  }
  lifecycle {
        ignore_changes = ["read_capacity", "write_capacity"]
    }

}


resource "aws_sns_topic" "user_updates_us-east-1_Animal" {             #SNS Topic creation 
  provider = "aws.us-east-1"
  name = "Animal_us-east-1_Alram"
}
####Alram creation for animal table  us-east-1 region 

resource "aws_cloudwatch_metric_alarm" "us-east-1_animal_read_capacity" {        
  provider = "aws.us-east-1"
  alarm_name                = "ReadCapacityUnitsLimitAlarm_us-east-1_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "ConsumedReadCapacityUnits"
  namespace                 = "aws/DynamoDB"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "240"
  alarm_description         = "Alarm when read capacity reaches 80% of my provisioned read capacity"
  dimensions {
               TableName="${aws_dynamodb_table.us-east-1.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-east-1_Animal.arn}"]
}


resource "aws_cloudwatch_metric_alarm" "us-east-1_animal_write_capacity" {
  alarm_name                = "ConsumedWriteCapacityUnits_us-east-1_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "ConsumedWriteCapacityUnits"
  namespace                 = "aws/DynamoDB"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "60"
  alarm_description         = "Alarm when write capacity reaches 80% of my provisioned read capacity"
  dimensions {
               TableName="${aws_dynamodb_table.us-east-1.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-east-1_Animal.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "us-east-1_animal_request_throteld_read" {
  provider = "aws.us-east-1"
  alarm_name                = "Throttledi_Read_Requests_us-east-1_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "ReadThrottleEvents"
  namespace                 = "aws/DynamoDB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "0"
  unit                      = "Count"
  alarm_description         =  "Alarm when my  read requests are exceeding provisioned throughput limits of a table"
  dimensions {
               TableName="${aws_dynamodb_table.us-east-1.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-east-1_Animal.arn}"]
}


resource "aws_cloudwatch_metric_alarm" "us-east-1_animal_request_throteld_write" {
  provider = "aws.us-east-1"
  alarm_name                = "Throttled_Write_Requests_us-east-1_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "WriteThrottleEvents"
  namespace                 = "aws/DynamoDB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "0"
  unit                      = "Count"
  alarm_description         =  "Alarm when my  write requests are exceeding provisioned throughput limits of a table"
  dimensions {
               TableName="${aws_dynamodb_table.us-east-1.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-east-1_Animal.arn}"]
}







resource "aws_cloudwatch_metric_alarm" "us-east-1_animal_Check_Failed_Requests" {
  provider = "aws.us-east-1"
  alarm_name                = "Conditiaonal_us-east-1_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "ConditionalCheckFailedRequests"
  namespace                 = "aws/DynamoDB"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "0"
  unit                      = "Count"
  alarm_description         =  "Alarm when my requests request are faild due to conditional check"
  dimensions {
               TableName="${aws_dynamodb_table.us-east-1.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-east-1_Animal.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "us-east-1_system_errors" {
  provider = "aws.us-east-1"
  alarm_name                = "System_errors_us-east-1_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "SystemErrors"
  namespace                 = "aws/DynamoDB"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "0"
  unit                      = "Count"
  alarm_description         =  "Alarm when my requests request are faild due to system errors"
  dimensions {
               TableName="${aws_dynamodb_table.us-east-1.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-east-1_Animal.arn}"]
}


#AutoScalling and Scalling policy for Animal table in us-east-1 region 

resource "aws_appautoscaling_target" "Animal_us-east-1_table_read_target" {
  provider = "aws.us-east-1"
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"

}


resource "aws_appautoscaling_policy" "Animal_us-east-1_table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-east-1_table_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-east-1_table_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_target" "Animal_us-east-1_table_write_target" {
  provider = "aws.us-east-1"
  depends_on = ["aws_appautoscaling_target.Animal_us-east-1_table_read_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"


}

resource "aws_appautoscaling_policy" "Animal_us-east-1_table_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-east-1_table_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-east-1_table_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-east-1_table_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}


resource "aws_appautoscaling_target" "Animal_us-east-1_index_read_target" {
  provider = "aws.us-east-1"
  depends_on = ["aws_appautoscaling_target.Animal_us-east-1_table_write_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}/index/OwnerIndec"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"

}

resource "aws_appautoscaling_policy" "Animal_us-east-1_index_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-east-1_index_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-east-1_index_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-east-1_index_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_target" "Animal_us-east-1_index_write_target" {
  provider = "aws.us-east-1"
  depends_on = ["aws_appautoscaling_target.Animal_us-east-1_index_read_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}/index/OwnerIndec"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace = "dynamodb"


}


resource "aws_appautoscaling_policy" "Animal_us-east-1_index_write_target" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-east-1_index_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-east-1_index_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-east-1_index_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}




###################### Animal Table in  us-west-2 region ############

resource "aws_dynamodb_table" "us-west-2" {
  provider = "aws.us-west-2"

  hash_key         = "AnimalType"
  range_key        = "AnimalName"  
  name             = "Animal"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity    = 5
  write_capacity   = 5
  
  server_side_encryption {
  enabled = true

  }
    point_in_time_recovery {
   enabled = true

   }

  attribute {
    name = "AnimalType"
    type = "S"
  }
    attribute {
    name = "AnimalName"
    type = "S"
  }
  attribute {
    name = "Owner"
    type = "S"
  }
  attribute {
    name = "Breed"
    type = "S"
  }
  
    global_secondary_index {
    name               = "OwnerIndec"
    hash_key           = "Owner"
    range_key          = "Breed"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
  }

  lifecycle {
        ignore_changes = ["read_capacity", "write_capacity"]
    }

}


####Alram creation for animal table  us-west-2 region 


resource "aws_sns_topic" "user_updates_us-west-2_Animal" {             #SNS Topic creation 
  provider = "aws.us-west-2"
  name = "Animal_us-west-2_Alram"
}
####Alram creation for animal table us-west-2 region 

resource "aws_cloudwatch_metric_alarm" "us-west-2_animal_read_capacity" {        
  provider = "aws.us-west-2"
  alarm_name                = "ReadCapacityUnitsLimitAlarm.us-west-2_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "ConsumedReadCapacityUnits"
  namespace                 = "aws/DynamoDB"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "240"
  alarm_description         = "Alarm when read capacity reaches 80% of my provisioned read capacity"
  dimensions {
               TableName="${aws_dynamodb_table.us-west-2.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-west-2_Animal.arn}"]
}


resource "aws_cloudwatch_metric_alarm" "us-west-2_animal_write_capacity" {
  provider = "aws.us-west-2"
  alarm_name                = "ConsumedWriteCapacityUnits.us-west-2_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "ConsumedWriteCapacityUnits"
  namespace                 = "aws/DynamoDB"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "60"
  alarm_description         = "Alarm when write capacity reaches 80% of my provisioned read capacity"
  dimensions {
               TableName="${aws_dynamodb_table.us-west-2.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-west-2_Animal.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "us-west-2_animal_request_throteld_read" {
  provider = "aws.us-west-2"
  alarm_name                = "Throttledi_Read_Requests.us-west-2_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "ReadThrottleEvents"
  namespace                 = "aws/DynamoDB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "0"
  unit                      = "Count"
  alarm_description         =  "Alarm when my  read requests are exceeding provisioned throughput limits of a table"
  dimensions {
               TableName="${aws_dynamodb_table.us-west-2.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-west-2_Animal.arn}"]
}


resource "aws_cloudwatch_metric_alarm" "us-west-2_animal_request_throteld_write" {
  provider = "aws.us-west-2"
  alarm_name                = "Throttled_Write_Requests.us-west-2_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "WriteThrottleEvents"
  namespace                 = "aws/DynamoDB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "0"
  unit                      = "Count"
  alarm_description         =  "Alarm when my  write requests are exceeding provisioned throughput limits of a table"
  dimensions {
               TableName="${aws_dynamodb_table.us-west-2.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-west-2_Animal.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "us-west-2_animal_Check_Failed_Requests" {
  provider = "aws.us-west-2"
  alarm_name                = "Conditiaonal.us-west-2_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "ConditionalCheckFailedRequests"
  namespace                 = "aws/DynamoDB"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "0"
  unit                      = "Count"
  alarm_description         =  "Alarm when my requests request are faild due to conditional check"
  dimensions {
               TableName="${aws_dynamodb_table.us-west-2.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-west-2_Animal.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "us-west-2_system_errors" {
  provider = "aws.us-west-2"
  alarm_name                = "System_errors.us-west-2_animal"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "SystemErrors"
  namespace                 = "aws/DynamoDB"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "0"
  unit                      = "Count"
  alarm_description         =  "Alarm when my requests request are faild due to system errors"
  dimensions {
               TableName="${aws_dynamodb_table.us-west-2.name}"
              }
  alarm_actions = ["${aws_sns_topic.user_updates_us-west-2_Animal.arn}"]
}

#AutoScalling and Scalling policy for Animal table in us-west-2 region 

resource "aws_appautoscaling_target" "Animal_us-west-2_table_read_target" {
  provider = "aws.us-west-2"
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-west-2.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"

}


resource "aws_appautoscaling_policy" "Animal_us-west-2_table_read_policy" {
  provider = "aws.us-west-2"
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-west-2_table_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-west-2_table_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-west-2_table_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_target" "Animal_us-west-2_table_write_target" {
  provider = "aws.us-west-2"
  depends_on = ["aws_appautoscaling_target.Animal_us-west-2_table_read_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"


}

resource "aws_appautoscaling_policy" "Animal_us-west-2_table_write_policy" {
  provider = "aws.us-west-2"
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.Animal_us-west-2_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-west-2_table_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-west-2_table_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-west-2_table_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}


resource "aws_appautoscaling_target" "Animal_us-west-2_index_read_target" {
  provider = "aws.us-west-2"
  depends_on = ["aws_appautoscaling_target.Animal_us-west-2_table_write_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-west-2.name}/index/OwnerIndec"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"

}

resource "aws_appautoscaling_policy" "Animal_us-west-2_index_read_policy" {
  provider = "aws.us-west-2"
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.Animal_us-west-2_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-west-2_index_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-west-2_index_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-west-2_index_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_target" "Animal_us-west-2_index_write_target" {
  provider = "aws.us-west-2"
  depends_on = ["aws_appautoscaling_target.Animal_us-west-2_index_read_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-west-2.name}/index/OwnerIndec"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace = "dynamodb"


}


resource "aws_appautoscaling_policy" "Animal_us-west-2_index_write_target" {
  provider = "aws.us-west-2"
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.Animal_us-west-2_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-west-2_index_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-west-2_index_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-west-2_index_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}



#Global Table creation 

resource "aws_dynamodb_global_table" "Animal" {
  depends_on = ["aws_dynamodb_table.us-east-1", "aws_dynamodb_table.us-west-2"]
  provider   = "aws.us-east-1"
 

  name = "Animal"

  replica {
    region_name = "us-east-1"
  }

  replica {
    region_name = "us-west-2"
  }


}



