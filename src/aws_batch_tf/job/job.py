from aws_batch_tf.aws.messages_queue import MessagesQueue
from aws_batch_tf.job.job_settings import JobSettings


def job() -> None:
    """Run the job."""
    settings = JobSettings()
    if settings.messages_queue_name is None:
        msg = "No messages queue name provided. Skipping message sending."
        raise ValueError(msg)

    messages_queue = MessagesQueue(name=settings.messages_queue_name, region_name=settings.region_name)
    messages_queue.push({"status": "OK", "message": settings.hello_message})


if __name__ == "__main__":
    job()
