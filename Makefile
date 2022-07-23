deploy_users_handler:
	cd functions/${lambda} \
	&& GOOS=linux GOARCH=amd64 go build -o main \
	&& zip main.zip main \
	&& rm main \
	&& aws --profile ots s3 cp main.zip s3://skillboard-lambda-functions/${lambda}_handler.zip \
	&& rm main.zip \
	&& aws --profile ots lambda update-function-code --function-name ${lambda}_handler --s3-bucket skillboard-lambda-functions --s3-key ${lambda}_handler.zip