FROM node:8-slim

# See https://crbug.com/795759
RUN apt-get update && apt-get install -yq libgconf-2-4 git-core

# Install latest chrome dev package.
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /src/*.deb

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install puppeteer so it's available in the container.
RUN yarn add puppeteer

# Add pptr user.
RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /node_modules

RUN (cd; wget https://bootstrap.pypa.io/get-pip.py; python get-pip.py && pip install awscli --upgrade)
RUN npm i npm && npm install github:nhmaha/aws-azure-login && chmod og+rwx -R /node_modules

# Run user as non privileged.
USER pptruser

COPY login.sh /home/pptruser

ENTRYPOINT /home/pptruser/login.sh
