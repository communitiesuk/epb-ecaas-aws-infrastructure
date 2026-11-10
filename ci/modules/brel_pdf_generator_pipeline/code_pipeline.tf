resource "aws_codepipeline" "brel_pdf_generator_pipeline" {
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
        BranchName           = var.github_branch_main
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "build-brel-pdf-generator-lambda"

    action {
      name             = "BuildBrelPdfGeneratorLambda"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_brel_pdf_generator_lambda_output"]

      configuration = {
        ProjectName   = module.codebuild_build_brel_pdf_generator_lambda.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "deploy-brel-pdf-generator-lambda-to-integration"

    action {
      name            = "DeployBrelPdfGeneratorLambdaToIntegration"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["build_brel_pdf_generator_lambda_output", "source_output"]

      configuration = {
        ProjectName   = module.codebuild_deploy_brel_pdf_generator_lambda_integration.codebuild_name
        PrimarySource = "source_output"
      }
    }
  }
}