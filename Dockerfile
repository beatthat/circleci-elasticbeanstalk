FROM circleci/python:3.6

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
    sudo apt-get install -y git-lfs
    
RUN sudo apt-get update && \
    sudo apt-get install rsync && \
    sudo apt-get clean && \
    sudo rm -rf /src/*.deb /var/lib/apt/lists/* /tmp/* /var/tmp/*


# PROJECT_ROOT is path to git checkout. The below is the default
ENV PROJECT_ROOT=/home/circleci/project
ENV EBS_TOOLS=/ebs-tools
ENV PATH=${PATH}:/home/circleci/.local/bin
COPY --chown=circleci:circleci ebs-tools /ebs-tools
RUN chmod -R a+x ${EBS_TOOLS}/bin
ENV PATH=${PATH}:${EBS_TOOLS}/bin

# so in circleci run step you can: eval ${EBS_TOOLS_ENV_INIT}
ENV EBS_TOOLS_ENV_INIT="echo 'source \${EBS_TOOLS}/bin/env_init.sh' >> \${BASH_ENV}"

COPY --chown=circleci:circleci requirements.txt /tmp
RUN pip install --user -r /tmp/requirements.txt && rm /tmp/requirements.txt