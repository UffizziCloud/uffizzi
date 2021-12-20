# Uffizzi App 

**The primary REST API for creating and managing Previews**

While it provides a documented REST API for anyone to use, it's most valuable when used with the open-source [`uffizzi_cli`](https://github.com/UffizziCloud/uffizzi_cli).  

## Uffizzi Overview

Uffizzi is the Full-stack Previews Engine that makes it easy for your team to preview code changes before merging—whether frontend, backend or microserivce. Define your full-stack apps with a familiar syntax based on Docker Compose, then Uffizzi will create on-demand test environments when you open pull requests or build new images. Preview URLs are updated when there’s a new commit, so your team can catch issues early, iterate quickly, and accelerate your release cycles.  

## Getting started with Uffizzi  

The fastest and easiest way to get started with Uffizzi is via the fully hosted version available at https://uffizzi.com, which includes free plans for small team and qualifying open-source projects.  

Alternatively, you can self-host Uffizzi via the open-source repositories available here on GitHub. The remainder of this README is intended for users interested in self-hosting Uffizzi or for those who are just curious about how Uffizzi works.

## Uffizzi Architecture  

Uffizzi consists of the following components:  

* Uffizzi App (this repository) - The primary REST API for creating and managing Previews  
* [Uffizzi Controller](https://github.com/UffizziCloud/uffizzi_controller) - A smart proxy service that handles requests from Uffizzi App to the Kubernetes API  
* [Uffizzi CLI](https://github.com/UffizziCloud/uffizzi_cli) - A command-line interface for Uffizzi App     
* [Uffizzi Dashboard](https://app.uffizzi.com) - A graphical user interface for Uffizzi App (not available for self-hosting)

To host Uffizzi yourself, you will also need the following external dependencies:  

 * Kubernetes (k8s) cluster  
 * Postgres database  
 * Redis cache  

## Design  

This `uffizzi_app` acts as a REST API for the [`uffizzi_cli`](https://github.com/UffizziCloud/uffizzi_app) and [`Uffizzi Dashboard`](https://app.uffizzi.com) interfaces. It requires [`uffizzi_controller`](https://github.com/UffizziCloud/uffizzi_controller) as a supporting service.


## INTRODUCTION-

# Why this Open Source Project is Needed:

It's 2021 and these are our observations after 2+ years interviewing over 150+ developers, DevOps, and cross-functional team members across a variety of industries and at various levels of business maturity - from nascent start-ups to long-running enterprises.

-It's universally beneficial to bring QA into the Development process, to catch issues early, iterate quickly, and to merge clean code into Develop or Main.

-Virtually all teams from can benefit from a Full-Stack Preview capability and industry defined best practices for Previewing i.e. Continuous Previews.

-Many teams - typically more advanced teams with time, resources, and expertise - build and maintain an internal Full-Stack Preview capability. 

-Most teams lack the time, resources, and expertise to build and maintain an internal capability - for most a Preview tool is on their wish list but there's no clear choices or guidelines provided by either Open Source community, CNCF, or the industry as a whole.

-As a community we are not actively collaborating or innovating towards a well-defined Preview Process and technical capability: we should be. 

-There's no official Open Source Preview specific tool within the CNCF.  There are several CI, CD, and deployment tools within the CNCF and more broadly across the industry.  These tools, while useful, are fundamentally lacking for the task of Previewing and the requisite collaborative teamwork across cross-functional teams to produce quality working software. 

-Previewing should be more about collaboration between the teammate(s) writing the code and the teammate(s) previewing what they've done than it is about deploying - "Individuals and Interactions over processes and tools." https://agilemanifesto.org/

-The maturity of cloud native development, containerization, and container orchestration have laid the foundation for a Preview capability and best practices that nearly all teams can benefit from.

# What this Project/Team aims to accomplish:

-Lead a community effort to define best practices for Previewing and to provide a modular, purpose-built, open source preview tool that will more broadly enable teams to benefit from a Preview capability.

-Provide well-defined purpose-driven guidelines for Previewing - see https://cpmanifesto.org 

___________________________________________________________________________________


uffizzi_app is the primary web application than enables a Continuous Previews capability per https://cpmanifesto.org (https://github.com/UffizziCloud/Continuous_Previews_Manifesto)

We are in the process of open sourcing core components of uffizzi following an open core model. uffizzi_controller (https://github.com/UffizziCloud/uffizzi_controller) has previously been released.

# Please FOLLOW this repository for RELEASE updates and opportunities to CONTRIBUTE o/a December 2021.
