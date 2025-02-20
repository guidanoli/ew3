import time
import subprocess
import logging
import requests
import json
from requests.exceptions import RequestException
from openai import OpenAI

from cartesi import abi, DApp, Rollup, RollupData
from pydantic import BaseModel

logging.basicConfig(level="INFO")
logger = logging.getLogger(__name__)


######################################################################
# Configuration constants
######################################################################

class ModelParameters(BaseModel):
    model_path: str
    context_size: int
    cache_type_k: str
    cache_type_v: str


KNOWN_MODELS: dict[str, ModelParameters] = {
    "SmolLM2-135M-Instruct": ModelParameters(
        model_path="models/SmolLM2-135M-Instruct-Q8_0.gguf",
        context_size=8192,
        cache_type_k="f16",
        cache_type_v="f32"
    ),
    "SmolLM2-360M-Instruct": ModelParameters(
        model_path="models/SmolLM2-360M-Instruct-Q8_0.gguf",
        context_size=8192,
        cache_type_k="f16",
        cache_type_v="f32"
    ),
    "Qwen2.5-0.5B-Instruct": ModelParameters(
        model_path="models/Qwen2.5-0.5B-Instruct-Q8_0.gguf",
        context_size=32768,
        cache_type_k="f16",
        cache_type_v="f32"
    ),
    "Qwen2.5-Coder-0.5B-Instruct": ModelParameters(
        model_path="models/Qwen2.5-Coder-0.5B-Instruct-Q8_0.gguf",
        context_size=32768,
        cache_type_k="f16",
        cache_type_v="f32"
    ),
    "Qwen2.5-1.5B-Instruct": ModelParameters(
        model_path="models/Qwen2.5-1.5B-Instruct-Q8_0.gguf",
        context_size=32768,
        cache_type_k="f16",
        cache_type_v="f32"
    ),
    "Qwen2.5-Coder-1.5B-Instruct": ModelParameters(
        model_path="models/Qwen2.5-Coder-1.5B-Instruct-Q8_0.gguf",
        context_size=32768,
        cache_type_k="f16",
        cache_type_v="f32"
    ),
    "Qwen2.5-Math-1.5B-Instruct": ModelParameters(
        model_path="models/Qwen2.5-Math-1.5B-Instruct-Q8_0.gguf",
        context_size=4096,
        cache_type_k="f16",
        cache_type_v="f32"
    ),
    "SmolLM2-1.7B-Instruct": ModelParameters(
        model_path="models/SmolLM2-1.7B-Instruct-Q8_0.gguf",
        context_size=8192,
        cache_type_k="f16",
        cache_type_v="f32"
    ),
    "DeepSeek-R1-Distill-Qwen-1.5B": ModelParameters(
        model_path="models/DeepSeek-R1-Distill-Qwen-1.5B-Q8_0.gguf",
        context_size=65536,
        cache_type_k="q8_0",
        cache_type_v="f32"
    ),
    "DeepScaleR-1.5B-Preview": ModelParameters(
        model_path="models/DeepScaleR-1.5B-Preview-Q8_0.gguf",
        context_size=65536,
        cache_type_k="q8_0",
        cache_type_v="f32"
    ),
}

LOCAL_API_KEY = (
    "sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    "xxxxxxxxxxxxxxxxxx"
)


######################################################################
# Input and Output data models
######################################################################


class Message(BaseModel):
    content: str
    role: str


class Option(BaseModel):
    key: str
    value: str


class CompletionInput(BaseModel):
    completion_id: abi.UInt256
    model_name: str
    max_completion_tokens: abi.UInt256
    messages: list[Message]
    options: list[Option]
    callback_contract_address: abi.Address


class Usage(BaseModel):
    prompt_tokens: abi.UInt256
    completion_tokens: abi.UInt256


class CompletionNotice(BaseModel):
    completion_id: abi.UInt256
    callback_contract_address: abi.Address
    messages: list[Message]
    usage: Usage

######################################################################
# LLama.cpp Server Interface
######################################################################


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
        bool: True if endpoint becomes available with expected status, False
              otherwise
    """
    for attempt in range(max_retries):
        try:
            response = requests.get(url, timeout=timeout)

            # Check if response is JSON and has expected content
            if response.status_code == 200:
                data = response.json()
                if isinstance(data, dict) and data.get("status") == "ok":
                    logger.debug(
                        f"Health check succeeded after {attempt+1} attempts"
                    )
                    return True

        except (RequestException, json.JSONDecodeError) as e:
            # Catch network errors and invalid JSON responses
            logger.debug(
                f"Attempt {attempt + 1}/{max_retries} failed: {str(e)}"
            )

        # Sleep before next retry, but not if we've exhausted all retries
        if attempt < max_retries - 1:
            time.sleep(retry_delay)

    logger.error(f"Health check failed after {max_retries} attempts")
    return False


class LlamaCppServer:

    def __init__(
        self,
        model_name: str,
        model_parameters: ModelParameters,
        max_completion_tokens: int = 32,
        seed: int = 0,
        temperature: float = 0.8,
    ):
        self.model_name = model_name
        self.model_parameters = model_parameters
        self.seed = seed
        self.max_completion_tokens = max_completion_tokens
        self.temperature = temperature

        self.process: subprocess.Popen | None = None
        self.base_url = "http://127.0.0.1:8080/v1"

    def apply_options(self, options: list[Option]):
        """Apply the options to the server"""

        if self.process is not None:
            logger.info("Server already running. Not applying options.")
            return

        for option in options:
            if option.key == "seed":
                self.seed = int(option.value)
            elif option.key == "temperature":
                self.temperature = float(option.value)
            else:
                logger.warning(f"Unknown option: key={repr(option.key)} "
                               f"value={repr(option.value)}")

    def start(self):
        """Spawn the llama.cpp server process if needed"""

        if self.process is not None:
            logger.info("Server already running. Not starting again.")
            return

        logger.debug("Starting llama.cpp server")
        self.process = subprocess.Popen(
            [
                "llama-server",
                "--model", self.model_parameters.model_path,
                "--ctx-size", str(self.model_parameters.context_size),
                "--cache-type-k", self.model_parameters.cache_type_k,
                "--cache-type-v", self.model_parameters.cache_type_v,
                "--seed", str(self.seed),
                "--n-predict", str(self.max_completion_tokens),
                "--no-warmup"
            ]
        )
        logger.debug(f"Server started with pid {self.process.pid}")

        wait_for_health_endpoint(
            url="http://127.0.0.1:8080/health",
            timeout=0.25,
            max_retries=600,
            retry_delay=0.25
        )
        logger.debug("Server health check passed")

    def stop(self):
        if self.process:
            self.process.terminate()
            self.process = None

    def predict(self, messages: list[Message]):
        self.start()

        client = OpenAI(
            api_key=LOCAL_API_KEY,
            base_url=self.base_url,
            timeout=24*60*60,
        )

        payload = [dict(msg) for msg in messages]

        logger.info(f"Running inference with payload: {repr(payload)}")

        completion = client.chat.completions.create(
            model=self.model_name,
            messages=payload
        )

        logger.info(f"Inference finish with completion: {repr(completion)}")

        return completion


######################################################################
# DApp Interface
######################################################################

dapp = DApp()


def str2hex(str):
    """Encodes a string as a hex string"""
    return "0x" + str.encode("utf-8").hex()


@dapp.advance()
def handle_advance(rollup: Rollup, data: RollupData):
    logger.info(f"Received advance request data {data}")

    payload = data.bytes_payload()
    completion_input = abi.decode_to_model(data=payload, model=CompletionInput)

    model_name = completion_input.model_name
    if model_name not in KNOWN_MODELS:
        logger.error(f"Unknown model: {model_name}")
        return False

    model_params = KNOWN_MODELS[model_name]

    server = LlamaCppServer(
        model_name=model_name,
        model_parameters=model_params,
        max_completion_tokens=completion_input.max_completion_tokens,
    )

    server.apply_options(options=completion_input.options)

    results = server.predict(messages=completion_input.messages)

    completion_notice = CompletionNotice(
        completion_id=completion_input.completion_id,
        callback_contract_address=completion_input.callback_contract_address,
        usage=Usage(
            prompt_tokens=results.usage.prompt_tokens,
            completion_tokens=results.usage.completion_tokens
        ),
        messages=[
            Message(
                role=choice.message.role,
                content=choice.message.content
            )
            for choice in results.choices
        ]
    )
    notice_payload = '0x' + abi.encode_model(completion_notice).hex()
    rollup.notice(notice_payload)

    server.stop()

    return True


@dapp.inspect()
def handle_inspect(rollup: Rollup, data: RollupData) -> bool:
    payload = data.str_payload()
    logger.info("Echoing '%s'", payload)
    rollup.report(str2hex(payload))
    return True


if __name__ == "__main__":
    dapp.run()
