RPC_URL= localhost:8545
PROJECT_ID= thinkchain
TMP_DIRS= broadcast cache completionIds deployments models out requests results

.PHONY: deploy
deploy:
	@contracts/deploy.sh --fork-url $(RPC_URL)

.PHONY: request
request: deploy
	@contracts/request.sh --fork-url $(RPC_URL)

.PHONY: clean
clean:
	@cd contracts && rm -rfv $(TMP_DIRS)

.PHONY: setup-frontend
setup-frontend:
	@cd frontend && npm install

.PHONY: run-frontend-dev
run-frontend-dev: setup-frontend frontend/.env
	@cd frontend && npm run dev

frontend/.env: deploy
	@echo "VITE_WALLET_CONNECT_PROJECT_ID=$(PROJECT_ID)" > $@
	@echo "VITE_COMPLETION_CONTRACT_ADDRESS=$(shell cat contracts/deployments/CoprocessorCompleter)" >> $@
	@echo "VITE_CALLBACK_CONTRACT_ADDRESS=$(shell cat contracts/deployments/SimpleCallback)" >> $@
