CloudFormation do
  Description("AWS CloudFormation Sample Template UpdateTutorial Part 2: Sample template that can be used to test EC2 updates. **WARNING** This template creates an Amazon Ec2 Instance. You will be billed for the AWS resources used if you create a stack from this template.")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("WebServerInstanceType") do
    Description("WebServer EC2 instance type")
    Type("String")
    Default("m1.small")
    AllowedValues([
  "t1.micro",
  "m1.small",
  "m1.medium",
  "m1.large",
  "m1.xlarge",
  "m2.xlarge",
  "m2.2xlarge",
  "m2.4xlarge",
  "m3.xlarge",
  "m3.2xlarge",
  "c1.medium",
  "c1.xlarge",
  "cc1.4xlarge",
  "cc2.8xlarge",
  "cg1.4xlarge"
])
    ConstraintDescription("must be a valid EC2 instance type.")
  end

  Mapping("AWSInstanceType2Arch", {
  "c1.medium"   => {
    "Arch" => "64"
  },
  "c1.xlarge"   => {
    "Arch" => "64"
  },
  "cc1.4xlarge" => {
    "Arch" => "64HVM"
  },
  "cc2.8xlarge" => {
    "Arch" => "64HVM"
  },
  "cg1.4xlarge" => {
    "Arch" => "64HVM"
  },
  "m1.large"    => {
    "Arch" => "64"
  },
  "m1.medium"   => {
    "Arch" => "64"
  },
  "m1.small"    => {
    "Arch" => "32"
  },
  "m1.xlarge"   => {
    "Arch" => "64"
  },
  "m2.2xlarge"  => {
    "Arch" => "64"
  },
  "m2.4xlarge"  => {
    "Arch" => "64"
  },
  "m2.xlarge"   => {
    "Arch" => "64"
  },
  "m3.2xlarge"  => {
    "Arch" => "64"
  },
  "m3.xlarge"   => {
    "Arch" => "64"
  },
  "t1.micro"    => {
    "Arch" => "32"
  }
})

  Mapping("AWSRegionArch2AMI", {
  "ap-northeast-1" => {
    "32"    => "ami-0644f007",
    "64"    => "ami-0a44f00b",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "ap-southeast-1" => {
    "32"    => "ami-b4b0cae6",
    "64"    => "ami-beb0caec",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "ap-southeast-2" => {
    "32"    => "ami-b3990e89",
    "64"    => "ami-bd990e87",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "eu-west-1"      => {
    "32"    => "ami-973b06e3",
    "64"    => "ami-953b06e1",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "sa-east-1"      => {
    "32"    => "ami-3e3be423",
    "64"    => "ami-3c3be421",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "us-east-1"      => {
    "32"    => "ami-31814f58",
    "64"    => "ami-1b814f72",
    "64HVM" => "ami-0da96764"
  },
  "us-west-1"      => {
    "32"    => "ami-11d68a54",
    "64"    => "ami-1bd68a5e",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "us-west-2"      => {
    "32"    => "ami-38fe7308",
    "64"    => "ami-30fe7300",
    "64HVM" => "NOT_YET_SUPPORTED"
  }
})

  Resource("WebServerSecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("GroupDescription", "Enable HTTP")
    Property("SecurityGroupIngress", [
  {
    "CidrIp"     => "0.0.0.0/0",
    "FromPort"   => "80",
    "IpProtocol" => "tcp",
    "ToPort"     => "80"
  }
])
  end

  Resource("Endpoint") do
    Type("AWS::EC2::EIP")
    Property("InstanceId", Ref("WebServerHost"))
  end

  Resource("WebServerHost") do
    Type("AWS::EC2::Instance")
    Metadata("Comment", "Install a simple PHP application")
    Metadata("AWS::CloudFormation::Init", {
  "config" => {
    "files"    => {
      "/etc/cfn/cfn-hup.conf"                   => {
        "content" => FnJoin("", [
  "[main]\n",
  "stack=",
  Ref("AWS::StackId"),
  "\n",
  "region=",
  Ref("AWS::Region"),
  "\n"
]),
        "group"   => "root",
        "mode"    => "000400",
        "owner"   => "root"
      },
      "/etc/cfn/hooks.d/cfn-auto-reloader.conf" => {
        "content" => FnJoin("", [
  "[cfn-auto-reloader-hook]\n",
  "triggers=post.update\n",
  "path=Resources.WebServerHost.Metadata.AWS::CloudFormation::Init\n",
  "action=/opt/aws/bin/cfn-init -s ",
  Ref("AWS::StackId"),
  " -r WebServerHost ",
  " --region     ",
  Ref("AWS::Region"),
  "\n",
  "runas=root\n"
])
      },
      "/var/www/html/index.php"                 => {
        "content" => FnJoin("", [
  "<?php\n",
  "echo '<h1>AWS CloudFormation sample PHP application</h1>';\n",
  "echo 'Updated version via UpdateStack';\n ",
  "?>\n"
]),
        "group"   => "apache",
        "mode"    => "000644",
        "owner"   => "apache"
      }
    },
    "packages" => {
      "yum" => {
        "httpd" => [],
        "php"   => []
      }
    },
    "services" => {
      "sysvinit" => {
        "httpd"    => {
          "enabled"       => "true",
          "ensureRunning" => "true"
        },
        "sendmail" => {
          "enabled"       => "false",
          "ensureRunning" => "false"
        }
      }
    }
  }
})
    Property("ImageId", FnFindInMap("AWSRegionArch2AMI", Ref("AWS::Region"), FnFindInMap("AWSInstanceType2Arch", Ref("WebServerInstanceType"), "Arch")))
    Property("InstanceType", Ref("WebServerInstanceType"))
    Property("SecurityGroups", [
  Ref("WebServerSecurityGroup")
])
    Property("UserData", FnBase64(FnJoin("", [
  "#!/bin/bash\n",
  "yum update -y aws-cfn-bootstrap\n",
  "# Helper function\n",
  "function error_exit\n",
  "{\n",
  "  /opt/aws/bin/cfn-signal -e 1 -r \"$1\" '",
  Ref("WebServerWaitHandle"),
  "'\n",
  "  exit 1\n",
  "}\n",
  "# Install the simple web page\n",
  "/opt/aws/bin/cfn-init -s ",
  Ref("AWS::StackId"),
  " -r WebServerHost ",
  "         --region ",
  Ref("AWS::Region"),
  " || error_exit 'Failed to run cfn-init'\n",
  "# Start up the cfn-hup daemon to listen for changes to the Web Server metadata\n",
  "/opt/aws/bin/cfn-hup || error_exit 'Failed to start cfn-hup'\n",
  "# All done so signal success\n",
  "/opt/aws/bin/cfn-signal -e 0 -r \"WebServer setup complete\" '",
  Ref("WebServerWaitHandle"),
  "'\n"
])))
  end

  Resource("WebServerWaitHandle") do
    Type("AWS::CloudFormation::WaitConditionHandle")
  end

  Resource("WebServerWaitCondition") do
    Type("AWS::CloudFormation::WaitCondition")
    DependsOn("WebServerHost")
    Property("Handle", Ref("WebServerWaitHandle"))
    Property("Timeout", "300")
  end

  Output("WebsiteURL") do
    Description("Application URL")
    Value(FnJoin("", [
  "http://",
  Ref("Endpoint")
]))
  end
end
