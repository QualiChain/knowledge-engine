FROM python:3.10.1-slim-bullseye
MAINTAINER Philipp D. Rohde <philipp.rohde@tib.eu>

ENV VERSION="0.3.1-qc"

# install dependencies
COPY requirements.txt /DeTrusty/requirements.txt
RUN python -m pip install --upgrade --no-cache-dir pip==21.1.* setuptools==57.0.0 gunicorn==20.1.* && \
    python -m pip install --no-cache-dir -r /DeTrusty/requirements.txt

# copy the source code into the container
COPY . /DeTrusty
RUN cd /DeTrusty && python3 setup.py install && mkdir -p Config
WORKDIR /DeTrusty/DeTrusty

# start the Flask app
ENTRYPOINT ["gunicorn", "-c", "/DeTrusty/DeTrusty/gunicorn.conf.py", "flaskr:app"]
