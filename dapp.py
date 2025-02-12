import time
import subprocess
import logging
import requests
import time
import json
from requests.exceptions import RequestException
from os import environ
from openai import OpenAI

logging.basicConfig(level="INFO")
logger = logging.getLogger(__name__)

def wait_for_health_endpoint(
    url: str,
    timeout: int = 5,
    max_retries: int = 60,
    retry_delay: float = 1.0
) -> bool:
    """
    Wait for a health endpoint to become available and return expected status.

    Args:
        url: The health check endpoint URL
        timeout: Request timeout in seconds
        max_retries: Maximum number of retry attempts
        retry_delay: Delay between retries in seconds

    Returns:
        bool: True if endpoint becomes available with expected status, False otherwise
    """
    for attempt in range(max_retries):
        try:
            response = requests.get(url, timeout=timeout)

            # Check if response is JSON and has expected content
            if response.status_code == 200:
                data = response.json()
                if isinstance(data, dict) and data.get("status") == "ok":
                    print(f"Health check succeeded after {attempt + 1} attempts")
                    return True

        except (RequestException, json.JSONDecodeError) as e:
            # Catch network errors and invalid JSON responses
            print(f"Attempt {attempt + 1}/{max_retries} failed: {str(e)}")

        # Sleep before next retry, but don't sleep if we've exhausted all retries
        if attempt < max_retries - 1:
            time.sleep(retry_delay)

    print(f"Health check failed after {max_retries} attempts")
    return False

def handle_advance(data):
    logger.info(f"Received advance request data {data}")

    # Start llama.cpp server
    process = subprocess.Popen(["llama-server",
        "--model", "models/SmolLM2-135M-Instruct-Q8_0.gguf",
        "--ctx-size", "0",
        "--seed", "0",
        "--n-predict", "32",
        "--no-warmup"
    ])

    # Wait until http://127.0.0.1:8080/health is available
    success = wait_for_health_endpoint(
        url="http://127.0.0.1:8080/health",
        timeout=0.25,
        max_retries=600,
        retry_delay=0.25
    )

    # Connect to server
    client = OpenAI(
        api_key = "sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        base_url = "http://127.0.0.1:8080/v1"
    )

    # Request completion
    completion = client.chat.completions.create(
        model="some-model",
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {
                "role": "user",
                "content": "Who are you?"
            }
        ]
    )

    # Print completions
    print(completion.choices)

    # Terminate the server
    process.terminate()

    return "accept"

def handle_inspect(data):
    logger.info(f"Received inspect request data {data}")
    return "accept"

# used when running in the HOST to for quick testing (REMOVE ME later)
if not 'ROLLUP_HTTP_SERVER_URL' in environ:
    handle_advance("hello")
    exit()

rollup_server = environ["ROLLUP_HTTP_SERVER_URL"]
logger.info(f"HTTP rollup_server url is {rollup_server}")

handlers = {
    "advance_state": handle_advance,
    "inspect_state": handle_inspect,
}

finish = {"status": "accept"}

while True:
    logger.info("Sending finish")
    response = requests.post(rollup_server + "/finish", json=finish)
    logger.info(f"Received finish status {response.status_code}")
    if response.status_code == 202:
        logger.info("No pending rollup request, trying again")
    else:
        rollup_request = response.json()
        data = rollup_request["data"]
        handler = handlers[rollup_request["request_type"]]
        finish["status"] = handler(rollup_request["data"])
