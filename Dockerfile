FROM ubuntu:xenial

# Install the necessary packages for Elixir
RUN apt-get update && \
    apt-get install -y wget git build-essential && \
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    apt-get install -y esl-erlang elixir

# Create the application directory and copy the code

# RUN rm -rf app
# WORKDIR /app
RUN mkdir /source
COPY . /source

WORKDIR /source/apps

# Install the dependencies and compile the application
RUN mix do local.hex --force, local.rebar --force, deps.get, deps.compile
# Run the application
# CMD ["mix", "run", "--no-halt"]
CMD tail -f /var/log/alternatives.log
# CMD [ "ls", "-al" ]
# CMD tail -f mix.exs
# CMD ["iex", "-S", "mix"]