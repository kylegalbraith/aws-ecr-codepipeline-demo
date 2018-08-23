variable "image_name" {
  type = "string"
}

module "codecommit-cicd" {
  source                    = "git::https://github.com/slalompdx/terraform-aws-codecommit-cicd.git?ref=master"
  repo_name                 = "docker-image-build"                                                             # Required
  organization_name         = "kylegalbraith"                                                                  # Required
  repo_default_branch       = "master"                                                                         # Default value
  aws_region                = "us-west-2"                                                                      # Default value
  char_delimiter            = "-"                                                                              # Default value
  environment               = "dev"                                                                            # Default value
  build_timeout             = "5"                                                                              # Default value
  build_compute_type        = "BUILD_GENERAL1_SMALL"                                                           # Default value
  build_image               = "aws/codebuild/docker:17.09.0"                                                   # Default value
  build_privileged_override = "true"                                                                           # Default value
  test_buildspec            = "buildspec_test.yml"                                                             # Default value
  package_buildspec         = "buildspec.yml"                                                                  # Default value
  force_artifact_destroy    = "true"                                                                           # Default value
}

resource "aws_ecr_repository" "image_repository" {
  name = "${var.image_name}"
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "serverless-codebuild-automation-policy"
  role = "${module.codecommit-cicd.codebuild_role_name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
POLICY
}

output "repo_url" {
  depends_on = ["module.codecommit-cicd"]
  value      = "${module.codecommit-cicd.clone_repo_https}"
}

output "codepipeline_role" {
  depends_on = ["module.codecommit-cicd"]
  value      = "${module.codecommit-cicd.codepipeline_role}"
}

output "codebuild_role" {
  depends_on = ["module.codecommit-cicd"]
  value      = "${module.codecommit-cicd.codebuild_role}"
}

output "ecr_image_respository_url" {
  depends_on = ["${aws_ecr_repository.image_repository}"]
  value      = "${aws_ecr_repository.image_repository.repository_url}"
}
