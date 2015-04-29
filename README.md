# Overview

The salt state for installing certificates on windows systems that can run powershell commands

## Prerequisites

#### (1) Setup the certificates in the pillar configuration

See the pillar.example for how to do this. Note that you can have more than one certificate be installed at a time. Also note that if the certificate already exists in the trusted store, it should not get re-installed.