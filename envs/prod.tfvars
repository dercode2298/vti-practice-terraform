vpc_name = "hungnv-tf-vpc"

cidrvpc = "10.0.0.0/16"

tags = {
    Name  = "hungnv-tf-vpc"
    Owner = "hungnv"
    # text = "lele"
}

az_count = 3

vm-config = {
    vm1 = {
        instance_type = "t2.small"
        tags = {
            "ext-name" = "vm1"
            "func"     = "test"
        }
    }
    vm2 = {
        instance_type = "t2.medium"
        tags = {
            "ext-name" = "vm2"
            "func"     = "test2"
        }
    }
}

bastion_definition = {
    bastion1 = {
        bastion_name                = "bastion1"
        bastion_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAr..."
        bastion_ami                 = "ami-12345678"
        bastion_instance_class      = "t2.micro"
        trusted_ips                 = ["0.0.0.0/0"]
        user_data_base64            = "IyEvYmluL2Jhc2gKZWNobyAiSGVsbG8gV29ybGQiCg=="
        associate_public_ip_address = true
        bastion_monitoring          = true
        ext-tags                    = {
            "env" = "prod"
        }
        func = "bastion"
    }
}

create_s3_bucket = true
