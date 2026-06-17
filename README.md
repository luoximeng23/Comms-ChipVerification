# Comms-ChipVerification

UCAgent Docker image for chip verification environment.

## Contents

- Verilator 5.020
- Picker 0.9.0
- SWIG 4.2.0
- UCAgent 0.9.1
- Comms_Verification plugin
- Workspace: async_fifo, adder

## Usage

```bash
docker load -i ucagent-latest.tar.gz
docker run -it --name ucagent \n  -e OPENAI_API_BASE=http://your-llm:port/v1 \n  -e OPENAI_API_KEY=your_key \n  -e OPENAI_MODEL=model_name \n  ucagent:latest
```