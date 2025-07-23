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
    name = "check-frontend"

    action {
      name            = "CheckFrontend"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = module.codebuild_check_front_end.codebuild_name
      }
    }
  }

  stage {
    name = "build-frontend"

    action {
      name             = "BuildFrontend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_frontend_output"]

      configuration = {
        ProjectName = module.codebuild_build_front_end.codebuild_name
      }
    }
  }

  stage {
    name = "deploy-frontend"

    action {
      name             = "DeployFrontend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output", "build_frontend_output"]
      output_artifacts = ["deploy_frontend_output"]

      configuration = {
        ProjectName   = module.codebuild_deploy_front_end.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "e2e-test-frontend"

    action {
      name             = "E2eTestFrontend"
      category         = "Test"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["e2e_test_frontend_output"]

      configuration = {
        ProjectName   = module.codebuild_e2e_test_front_end.codebuild_name
      }
    }
  }
}