resource "aws_codepipeline" "codepipeline" {
  name     = var.pipeline_name
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.codepipeline_bucket
    type     = "S3"
  }

  stage {
    name = "source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = format("%s/%s", var.github_organisation, var.github_repository)
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "build-front-end"

    action {
      name             = "BuildFrontEnd"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_front_end_output"]

      configuration = {
        ProjectName   = module.codebuild_build_front_end.codebuild_name
      }
    }
  }

  stage {
    name = "deploy-hem-lambda"

    action {
      name             = "DeployHEMLambda"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output", "build_front_end_output"]
      output_artifacts = ["deploy_hem_lambda_output"]

      configuration = {
        ProjectName   = module.codebuild_deploy_front_end.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }
}