FROM public.ecr.aws/lambda/python:3.11

COPY . ./

RUN pip install .

CMD ["app.main.lambda_handler"]
