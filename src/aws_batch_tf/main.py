from aws_batch_tf.settings import Settings
from aws_batch_tf.job_submitter import JobSubmitter


def main():
    settings = Settings()
    if not settings.job_queue or not settings.job_definition:
        raise ValueError(
            "Both job_queue and job_definition must be set in the settings."
        )

    submitter = JobSubmitter(
        job_queue=settings.job_queue,
        job_definition=settings.job_definition,
        region_name=settings.region_name,
    )
    job_id = submitter.submit(
        job_name="example-job",
        config={"EXAMPLE_ENV_VAR": "example_value"},
    )
    print(f"Submitted job with ID: {job_id}")


if __name__ == "__main__":
    main()
