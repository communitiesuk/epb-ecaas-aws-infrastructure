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

    action {
      name             = "HEMCoreSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["hem_core_source_output"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = format("%s/%s", var.github_organisation, var.hem_core_repository)
        BranchName           = var.hem_core_branch
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }

    action {
      name             = "ResolvePCDBDataSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["resolve_pcdb_data_source_output"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = format("%s/%s", var.github_organisation, "epb-ecaas-pcdb")
        BranchName           = "main"
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "test-hem-lambda"

    action {
      name             = "TestHEM"
      category         = "Test"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output", "hem_core_source_output"]
      output_artifacts = []

      configuration = {
        ProjectName   = module.codebuild_test_hem_lambda.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "build-hem-lambda"

    action {
      name             = "BuildHEMLambda"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output", "hem_core_source_output"]
      output_artifacts = ["build_hem_lambda_output"]

      configuration = {
        ProjectName   = module.codebuild_build_hem_lambda.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "deploy-hem-lambda-to-integration"

    action {
      name            = "DeployHEMLambdaToIntegration"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["build_hem_lambda_output", "source_output"]
      configuration = {
        ProjectName   = module.codebuild_deploy_hem_lambda_integration.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }
}

resource "aws_codepipeline" "codepipeline_production" {
  name     = "${var.pipeline_name}-production"
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
        BranchName           = var.github_branch_production
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }

    action {
      name             = "HEMCoreSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["hem_core_source_output"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = format("%s/%s", var.github_organisation, var.hem_core_repository)
        BranchName           = var.hem_core_branch
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }

    action {
      name             = "ResolvePCDBDataSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["resolve_pcdb_data_source_output"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = format("%s/%s", var.github_organisation, "epb-ecaas-pcdb")
        BranchName           = "main"
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "test-hem-lambda"

    action {
      name             = "TestHEM"
      category         = "Test"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output", "hem_core_source_output"]
      output_artifacts = []

      configuration = {
        ProjectName   = module.codebuild_test_hem_lambda.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "build-hem-lambda"

    action {
      name             = "BuildHEMLambda"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output", "hem_core_source_output"]
      output_artifacts = ["build_hem_lambda_output"]

      configuration = {
        ProjectName   = module.codebuild_build_hem_lambda.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "deploy-hem-lambda-to-staging"

    action {
      name            = "DeployHEMLambdaToStaging"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["build_hem_lambda_output", "source_output"]
      configuration = {
        ProjectName   = module.codebuild_deploy_hem_lambda_staging.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "deploy-hem-lambda-to-production"

    action {
      name            = "DeployHEMLambdaToProduction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["build_hem_lambda_output", "source_output"]
      configuration = {
        ProjectName   = module.codebuild_deploy_hem_lambda_production.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }
}
