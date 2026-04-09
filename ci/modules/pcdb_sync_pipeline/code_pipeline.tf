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
    name = "build-pcdb-sync"

    action {
      name             = "BuildPcdbSync"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_pcdb_sync_output"]

      configuration = {
        ProjectName = module.codebuild_build_lambda.codebuild_name
      }
    }
  }

  stage {
    name = "deploy-pcdb-sync"

    action {
      name            = "DeployFrontend"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output", "build_pcdb_sync_output"]
      configuration = {
        ProjectName   = module.codebuild_deploy_lambda.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }
}

resource "aws_codepipeline" "codepipeline_staging" {
  name     = "${var.pipeline_name}-staging"
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
  }

  stage {
    name = "build-pcdb-sync-staging"

    action {
      name             = "BuildPcdbSync"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_pcdb_sync_output"]

      configuration = {
        ProjectName = module.codebuild_build_lambda.codebuild_name
      }
    }
  }

  stage {
    name = "deploy-pcdb-sync-staging"

    action {
      name            = "DeployFrontend"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output", "build_pcdb_sync_output"]
      configuration = {
        ProjectName   = module.codebuild_deploy_pcdb_sync_staging.codebuild_name
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
  }

  stage {
    name = "build-pcdb-sync-production"

    action {
      name             = "BuildPcdbSync"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_pcdb_sync_output"]

      configuration = {
        ProjectName = module.codebuild_build_lambda.codebuild_name
      }
    }
  }

  stage {
    name = "deploy-pcdb-sync-production"

    action {
      name            = "DeployFrontend"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output", "build_pcdb_sync_output"]
      configuration = {
        ProjectName   = module.codebuild_deploy_pcdb_sync_production.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }
}