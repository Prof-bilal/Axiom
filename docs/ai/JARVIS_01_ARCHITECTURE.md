# Jarvis 0.1: Architecture Specification

**Status:** PROPOSAL - Architecture Design for Axiom's AI-Native Layer  
**Version:** 0.2.0  
**Date:** 2026-11-06  
**Phase:** Pre-Phase 7 (AI-native layer)  
**Author:** Axiom AI Architecture Team  

---

## Document Overview

This document specifies the **Jarvis 0.1** architecture for Axiom's AI-native layer. It builds upon the research findings in [JARVIS_01_RESEARCH.md](JARVIS_01_RESEARCH.md) and aligns with Axiom's existing AI contracts defined in [AI_ARCHITECTURE.md](AI_ARCHITECTURE.md), [AGENT_SYSTEM.md](AGENT_SYSTEM.md), [SYSTEM_AGENT_API.md](SYSTEM_AGENT_API.md), and [ROUTINES.md](ROUTINES.md).

---

## 1. Architecture Principles

### 1.1 Core Principles (Inherited from Axiom)

1. **One Parent, Many Children**
   - Single orchestrator (`assistantd`) owns planning and delegation
   - Children are workers, not peers
   - No second orchestrator

2. **Authority Never Grows**
   - Parent cannot grant child more than parent holds
   - Child cannot self-authorize
   - Child proposals re-enter parent → policy → executor path

3. **Model Output is Never Authority**
   - Child output is a proposal, not authorization
   - Only deterministic validator + policy engine produce typed requests

4. **Least Privilege by Default**
   - Each child gets narrowest tool surface for its purpose
   - Never the user's whole environment

### 1.2 Jarvis-Specific Principles

5. **Deterministic Orchestration**
   - Workflows are explicitly defined, not LLM-generated
   - Routing decisions are deterministic, not model-made

6. **Verifiable Evidence**
   - Every claim must have verifiable source
   - Cross-checking is mandatory for critical decisions

7. **User Empowerment**
   - Users can define custom agents
   - Customization is bounded and audited

8. **Security First**
   - All execution is sandboxed
   - Capabilities are explicitly granted
   - Fail closed on security violations

---

## 2. System Components

### 2.1 High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                           Axiom Session                                │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                      Overlay UI (Shell)                        │  │
│  │  ┌───────────────────────────────────────────────────────┐  │  │
│  │  │               User Interface Components               │  │  │
│  │  │  - AI Launcher/Palette                                │  │  │
│  │  │  - Agent Selection/Configuration                      │  │  │
│  │  │  - Research Results Display                           │  │  │
│  │  │  - Verification/Confirmation Dialogs                   │  │  │
│  │  └───────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                    │                              │
│                                    ▼                              │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    assistantd (Parent Orchestrator)              │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │  │
│  │  │  Planner    │  │   Router    │  │    Registry           │  │  │
│  │  │             │  │             │  │  - Built-in Agents    │  │  │
│  │  │             │  │             │  │  - User Agents        │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │                    Policy Engine                        │  │  │
│  │  │  - Capability Validation                              │  │  │
│  │  │  - Resource Scope Checking                            │  │  │
│  │  │  - Budget/Concurrency Limits                          │  │  │
│  │  │  - Authorization Requests                              │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                    │                              │
│                                    ▼                              │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    Executor Layer                             │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐        │  │
│  │  │  User Executor       │  │  system-agentd       │        │  │
│  │  │  (Unprivileged)      │  │  (Privileged)        │        │  │
│  │  └─────────────────────┘  └─────────────────────┘        │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                    │                              │
│                                    ▼                              │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    Sandbox Layer (Warden)                      │  │
│  │  ┌─────────────────────────────────────────────────────┐    │  │
│  │  │                MCP Workers                            │    │  │
│  │  │  - Tools (RepoSpine, web search, etc.)               │    │  │
│  │  │  - External Services (APIs, databases)               │    │  │
│  │  └─────────────────────────────────────────────────────┘    │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                    │                              │
│                                    ▼                              │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    Audit Layer                                 │  │
│  │  - Session D-Bus (UI integration)                            │  │
│  │  - System D-Bus (privileged ops)                              │  │
│  │  - SQLite (redacted activity)                                │  │
│  │  - Journal (privileged mutations)                           │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Component Details

#### 2.2.1 assistantd (Parent Orchestrator)

**Responsibilities:**
- Parse and understand user intent
- Generate bounded plans from requests
- Select appropriate child agents
- Coordinate multi-agent workflows
- Aggregate results from children
- Manage agent lifecycle (spawn, monitor, terminate)

**Subcomponents:**

1. **Planner**
   - Converts natural language to structured plans
   - Uses LLM for intent resolution (one-time only)
   - Generates deterministic execution graphs
   - Validates plans against capability catalog

2. **Router**
   - Implements provider selection logic
   - Manages model/adapter configurations
   - Routes requests to appropriate children
   - Handles fallbacks and retries

3. **Registry**
   - Maintains catalog of built-in agents
   - Stores user-defined agent definitions
   - Validates agent declarations
   - Handles agent versioning and updates

#### 2.2.2 Policy Engine

**Responsibilities:**
- Validate capability requests
- Check resource scopes
- Enforce budget and concurrency limits
- Request user authorization for sensitive operations
- Maintain authorization state

**Implementation:**
```rust
// Pseudocode for policy validation
struct PolicyRequest {
    request_id: String,
    caller: Identity,
    capability: Capability,
    arguments: Value,
    resource_scope: ResourceScope,
    budget: Budget,
}

struct PolicyResponse {
    allowed: bool,
    grants: Vec<Grant>,
    authorization_needed: bool,
    errors: Vec<PolicyError>,
}

fn validate_policy(request: PolicyRequest) -> PolicyResponse {
    // 1. Authenticate caller
    // 2. Validate capability exists
    // 3. Check resource scope
    // 4. Verify budget
    // 5. Check authorization requirements
    // 6. Return decision
}
```

#### 2.2.3 Executor Layer

**User Executor (Unprivileged):**
- Runs in user context
- Executes non-privileged operations
- Handles file operations, app launches, web requests
- Manages child agent processes

**system-agentd (Privileged):**
- Runs with elevated privileges
- Executes CRITICAL and SENSITIVE operations
- Uses Polkit for authorization
- Implements snapshot coordination
- Maintains separate audit journal

**From [SYSTEM_AGENT_API.md]:**
- Capabilities: system.info, processes.list, storage.analyze, apps.open, workspace.open, packages.install, services.start/stop, storage.clean, system.update
- All require explicit authorization
- No arbitrary commands, paths, or repositories

#### 2.2.4 Sandbox Layer (Warden)

**Integration with Warden:**
- Every MCP worker runs in Warden sandbox
- Policy-derived sandbox configuration
- Host-side egress proxy with allowlists
- JSONL audit logging
- Fail-closed on sandbox violations

**Sandbox Profiles:**
```yaml
# Example sandbox profile for research agent
profile: research-agent
backend: bubblewrap

filesystem:
  read_only:
    - /usr
    - /etc
  writable:
    - /tmp/agent-workdir
  blocked:
    - /home
    - /root

network:
  allow:
    - api.scite.ai:443
    - semanticscholar.org:443
    - pubmed.ncbi.nlm.nih.gov:443
  deny_default: true

capabilities:
  drop:
    - CAP_SYS_ADMIN
    - CAP_NET_ADMIN
  keep:
    - CAP_NET_BIND_SERVICE

limits:
  time: 300s
  memory: 1GB
  processes: 10
```

#### 2.2.5 Audit Layer

**Audit Events:**
- All capability invocations
- Authorization decisions
- Resource changes
- Network destinations
- Agent lifecycle events

**Audit Storage:**
- Session-level: SQLite with FTS5 for searchable activity
- System-level: Journal for privileged mutations
- Retention: Configurable with defaults
- Redaction: Secrets and sensitive data

---

## 3. Agent Architecture

### 3.1 Agent Definition Format

**File Format:** SKILL.md (YAML frontmatter + Markdown)

**Example:**
```yaml
---
name: research-agent
type: child-agent
version: 0.1.0
id: axiom.research.v1

# Metadata
purpose: Deep research with source verification and cross-checking
author: axiom-team
description: |
  Performs deep research on technical topics, verifies claims against
  multiple sources, and produces cited, verifiable outputs.

# Capabilities
dependencies:
  - system.info (OBSERVE)
  - storage.analyze (OBSERVE)
  - apps.open (NORMAL)

# Execution
model:
  primary: local:llama3.2:11b
  fallback: cloud:openai:gpt-4o
  provider_timeout: 30s

sandbox:
  profile: research-profile
  required: false

budget:
  max_steps: 20
  wall_time: 10m
  tokens: 10000
  cost: $1.00
  retry_limit: 3

context:
  repospine: project-root
  contextgit: research-branch

# Tools
tools:
  web_search:
    type: mcp
    server: axiom-web-search
    schema: search_v1
    config:
      max_results: 10
      timeout: 30s
      allowlist:
        - scite.ai
        - semanticscholar.org
        - arxiv.org

  document_parser:
    type: mcp
    server: repospine
    schema: document_v1
    config:
      max_size: 10MB
      formats: [pdf, html, markdown]

  citation_validator:
    type: builtin
    config:
      min_sources: 2
      max_age: 365d
      confidence_threshold: 0.8

# Evidence Requirements
evidence:
  required: true
  verification:
    method: cross-check
    min_sources: 2
    confidence: required
  output:
    format: markdown
    include: [citations, confidence, contradictions]

# Failure Handling
failure:
  policy: stop_and_report
  on_budget_exhausted: stop
  on_verification_failure: flag_and_escalate
  on_network_error: retry

# Security
permissions:
  network: allowlist
  filesystem: read-only
  processes: none
---

## Agent Behavior

You are a research assistant that performs deep, verifiable research.

### Instructions
1. Understand the research question
2. Break it into sub-queries
3. Search for authoritative sources
4. Cross-reference findings
5. Verify each claim against at least 2 sources
6. Annotate confidence levels
7. Flag contradictions and gaps
8. Synthesize findings with citations

### Constraints
- Never invent facts or sources
- Always attribute claims to sources
- If uncertain, flag as low confidence
- If contradictory, present both sides
- Maximum 20 search queries per session

### Examples
...
```

### 3.2 Agent Lifecycle

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Idle      │───▶│  Spawning   │───▶│   Running   │───▶│  Completing │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       ▲                   │              │              │
       │                   ▼              ▼              ▼
       │          ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
       │          │  Validating │  │   Executing │  │  Verifying  │
       │          └─────────────┘  └─────────────┘  └─────────────┘
       │                   │              │              │
       └───────────────────┴──────────────┴──────────────┘
                                  │
                                  ▼
                         ┌─────────────┐
                         │  Terminating│
                         └─────────────┘
```

**States:**
1. **Idle:** Agent definition loaded, waiting for request
2. **Spawning:** Creating sandbox, initializing tools, loading model
3. **Validating:** Checking policy, capabilities, budget
4. **Running:** Agent executing workflow
5. **Executing:** Running specific tool or operation
6. **Verifying:** Validating results and evidence
7. **Completing:** Finalizing output, recording audit
8. **Terminating:** Cleaning up resources

### 3.3 Built-in Agent Catalogue

| ID | Name | Purpose | Class | Sandbox | Phase |
|----|------|---------|-------|---------|-------|
| axiom.research.v1 | Research | Deep research with verification | OBSERVE | none | 7 |
| axiom.code.v1 | Code | Coding assistance, review | NORMAL | required | 7 |
| axiom.security.v1 | Security | Adversarial review | OBSERVE | required | 7 |
| axiom.marketing.v1 | Marketing | Content creation, analysis | NORMAL | none | 7 |
| axiom.automation.v1 | Automation | Workflow orchestration | SENSITIVE | required | 7 |
| axiom.content.v1 | Content | Multi-modal creation | NORMAL | none | 7 |
| axiom.data.v1 | Data | Analytics, insights | OBSERVE | none | 7 |
| axiom.context.v1 | Context | RepoSpine integration | OBSERVE | none | 7 |

### 3.4 User-Defined Agents

**Constraints:**
- Must use declarative SKILL.md format
- Can only use capabilities user already holds
- Schema validation required
- Purpose must not collide with built-ins
- Imported agents are untrusted input
- Editing invalidates grants, requires re-approval

**Approval Workflow:**
```
User defines agent → Schema validation → Purpose collision check → 
Review queue → Admin/Approver review → Approval/Rejection → 
Agent registered (if approved)
```

---

## 4. Workflow Execution

### 4.1 Request Processing Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        REQUEST LIFECYCLE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. USER REQUEST                                                  │
│     ┌─────────────────────┐                                       │
│     │  Input: Natural      │                                       │
│     │  language request    │                                       │
│     └──────────┬──────────┘                                       │
│                │                                                   │
│                ▼                                                   │
│  2. INTENT RESOLUTION                                             │
│     ┌─────────────────────┐                                       │
│     │  - Parse intent     │  ← LLM used HERE (one-time)         │
│     │  - Identify domain  │                                       │
│     │  - Extract parameters│                                       │
│     └──────────┬──────────┘                                       │
│                │                                                   │
│                ▼                                                   │
│  3. PLAN GENERATION                                              │
│     ┌─────────────────────┐                                       │
│     │  - Create bounded   │  ← Deterministic from now on       │
│     │    execution plan   │                                       │
│     │  - Select agents    │                                       │
│     │  - Define workflow  │                                       │
│     └──────────┬──────────┘                                       │
│                │                                                   │
│                ▼                                                   │
│  4. POLICY VALIDATION                                             │
│     ┌─────────────────────┐                                       │
│     │  - Check           │                                       │
│     │    capabilities    │                                       │
│     │  - Validate        │                                       │
│     │    resource scopes │                                       │
│     │  - Verify budget    │                                       │
│     │  - Request         │                                       │
│     │    authorization    │                                       │
│     └──────────┬──────────┘                                       │
│                │                                                   │
│          ┌─────┴─────┐                                             │
│          ▼           ▼                                             │
│     ┌─────────┐ ┌─────────┐                                       │
│     │ DENIED  │ │APPROVED │                                       │
│     └─────────┘ └────┬────┘                                       │
│                          │                                           │
│                          ▼                                           │
│  5. SANDBOX SETUP                                                │
│     ┌─────────────────────┐                                       │
│     │  - Create Warden    │                                       │
│     │    sandbox          │                                       │
│     │  - Configure        │                                       │
│     │    allowlists       │                                       │
│     │  - Initialize       │                                       │
│     │    MCP workers       │                                       │
│     └──────────┬──────────┘                                       │
│                │                                                   │
│                ▼                                                   │
│  6. EXECUTION                                                    │
│     ┌─────────────────────┐                                       │
│     │  - Spawn agents     │                                       │
│     │  - Run workflow     │                                       │
│     │  - Monitor progress │                                       │
│     │  - Enforce limits   │                                       │
│     └──────────┬──────────┘                                       │
│                │                                                   │
│                ▼                                                   │
│  7. VERIFICATION                                                 │
│     ┌─────────────────────┐                                       │
│     │  - Validate results │                                       │
│     │  - Check evidence   │                                       │
│     │  - Verify citations │                                       │
│     │  - Cross-check      │                                       │
│     └──────────┬──────────┘                                       │
│                │                                                   │
│                ▼                                                   │
│  8. AUDIT & RETURN                                               │
│     ┌─────────────────────┐                                       │
│     │  - Record audit     │                                       │
│     │  - Redact secrets   │                                       │
│     │  - Format response  │                                       │
│     │  - Return to user   │                                       │
│     └─────────────────────┘                                       │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Workflow Definition Language

**Format:** YAML-based workflow graphs

**Example:**
```yaml
# Research workflow definition
workflow:
  id: deep-research-v1
  name: Deep Research with Verification
  version: 0.1.0
  description: Performs deep research with multi-source verification

  # Input schema
  input:
    type: object
    properties:
      query:
        type: string
        description: The research question or topic
        max_length: 500
      min_sources:
        type: integer
        default: 3
        minimum: 2
        maximum: 10
      max_depth:
        type: integer
        default: 2
        minimum: 1
        maximum: 5

  # Workflow graph
  graph:
    start: decompose_query
    
    nodes:
      decompose_query:
        agent: research-agent
        task: decompose
        description: Break down the research question into sub-queries
        output: query_plan
        
      search_sources:
        agent: research-agent
        task: search
        description: Search for authoritative sources
        input: query_plan
        output: search_results
        config:
          max_results: 10
          min_confidence: 0.7
        
      extract_information:
        agent: research-agent
        task: extract
        description: Extract relevant information from sources
        input: search_results
        output: extracted_data
        
      cross_verify:
        agent: research-agent
        task: verify
        description: Cross-verify claims against multiple sources
        input: extracted_data
        output: verified_claims
        config:
          min_sources: 2
          confidence_threshold: 0.8
        
      detect_contradictions:
        agent: research-agent
        task: contradict
        description: Identify and resolve contradictions
        input: verified_claims
        output: resolved_claims
        
      synthesize_results:
        agent: research-agent
        task: synthesize
        description: Synthesize findings into coherent report
        input: resolved_claims
        output: research_report
        
    edges:
      - from: decompose_query
        to: search_sources
        
      - from: search_sources
        to: extract_information
        condition: search_results.count > 0
        
      - from: extract_information
        to: cross_verify
        
      - from: cross_verify
        to: detect_contradictions
        condition: cross_verify.contradictions_found
        
      - from: cross_verify
        to: synthesize_results
        condition: not cross_verify.contradictions_found
        
      - from: detect_contradictions
        to: synthesize_results

  # Budget
  budget:
    max_steps: 20
    wall_time: 15m
    tokens: 15000
    cost: $2.00
    
  # Evidence requirements
  evidence:
    required: true
    verification: cross-check
    min_sources: 2
    
  # Security
  sandbox:
    profile: research-profile
    network:
      allow:
        - scite.ai
        - semanticscholar.org
        - arxiv.org
      deny_default: true
```

---

## 5. Deterministic Routines Integration

### 5.1 Routine Definition

**From [ROUTINES.md]:**
- Versioned declarative graph of approved capabilities
- Bounded arguments, dependencies, deadlines, failure policy
- NO embedded shell, arbitrary JavaScript, dynamic tool names, model-generated approval

**Jarvis 0.1 Routine Format:**
```yaml
routine:
  id: morning-research-briefing
  version: 0.1.0
  owner: user@axiom
  
  description: |
    Daily research briefing that collects overnight developments
    in the user's focus areas and provides a summarized report.
  
  trigger:
    type: time
    schedule: "0 8 * * *"  # 8 AM daily
    timezone: user
  
  graph:
    nodes:
      check_news:
        capability: research.web_search
        args:
          query: "AI developments site:arxiv.org"
          max_results: 5
          since: 24h
        
      check_repos:
        capability: repospine.changes
        args:
          repo: /home/user/projects
          since: 24h
        
      check_email:
        capability: email.search
        args:
          query: "important label:inbox"
          max_results: 10
        
      generate_briefing:
        capability: research.synthesize
        args:
          sources:
            - check_news
            - check_repos
            - check_email
        
    edges:
      - from: check_news
        to: generate_briefing
      - from: check_repos
        to: generate_briefing
      - from: check_email
        to: generate_briefing
  
  capability_versions:
    research.web_search: 1.0
    repospine.changes: 1.0
    email.search: 1.0
    research.synthesize: 1.0
  
  resource_scopes:
    - filesystem:/home/user/projects
    - network:arxiv.org
    - email:user@gmail.com
  
  expected_destinations:
    - arxiv.org
    - gmail.googleapis.com
  
  permission_requirements:
    - OBSERVE: filesystem, network, email
  
  concurrency_policy:
    max_concurrent: 1
    queue: replace
  
  audit_retention:
    duration: 30d
    redact: [email_content]
```

### 5.2 Routine Execution

**Validation:**
- Routine ID/version must be registered
- Owner must have required capabilities
- Capability versions must match
- Resource scopes must be allowed
- Expected destinations must be permitted

**Execution:**
1. Validate routine definition
2. Check current time/trigger conditions
3. Resolve capability references
4. Request authorization (if needed)
5. Execute nodes in order
6. Handle failures according to policy
7. Audit all actions
8. Record completion status

---

## 6. Security Architecture

### 6.1 Security Layers

```
┌─────────────────────────────────────────────────────────────┐
│                        SECURITY LAYERS                            │
├─────────────────────────────────────────────────────────────┤
│                                                                 │
│  LAYER 1: POLICY                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  - Capability validation                                   │  │
│  │  - Resource scope checking                                 │  │
│  │  - Budget/concurrency enforcement                          │  │
│  │  - Authorization requirements                               │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  LAYER 2: SANDBOX (Warden)                                        │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  - bubblewrap namespaces                                   │  │
│  │  - User namespace isolation                                 │  │
│  │  - Filesystem restrictions                                  │  │
│  │  - Network allowlists                                       │  │
│  │  - Capability dropping                                      │  │
│  │  - Resource limits                                          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  LAYER 3: EXECUTOR                                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  - Separate user/privileged executors                       │  │
│  │  - Polkit for privileged operations                         │  │
│  │  - Typed capability contracts                               │  │
│  │  - No arbitrary commands                                    │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  LAYER 4: AUDIT                                                   │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  - All actions logged                                        │  │
│  │  - Secrets redacted                                          │  │
│  │  - Privileged mutations survive root rollback               │  │
│  │  - Bounded retention                                         │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 Threat Model

**Based on [THREAT_MODEL.md] (referenced):**

| Threat | Mitigation |
|--------|------------|
| Model prompt injection | Input validation, output sanitization |
| Tool description poisoning | Schema validation, tool allowlists |
| Changed tool lists | Version pinning, capability validation |
| Malformed/deep schemas | Size limits, schema validation |
| Output floods | Token limits, result truncation |
| Token audience mismatch | Auth validation, token scoping |
| Leaked credentials | Credential store, redaction |
| Local port exposure | Network isolation, allowlists |
| Reconnect/replay attacks | Session tokens, request IDs |
| Path escape | Filesystem restrictions, chroot |
| Network exfiltration | Egress proxy, allowlists |

### 6.3 Security Tests

**Required for Each Component:**
- Schema/denial/cancellation/failure tests
- Peer-authentication tests
- Capability-specific security tests

**Agent-Specific Tests:**
- Prompt injection resistance
- Tool misuse prevention
- Budget enforcement
- Sandbox escape attempts
- Network boundary testing

---

## 7. Integration Points

### 7.1 Axiom Shell Integration

**UI Components:**
- AI Launcher: Quick access to agents
- Agent Configurator: Manage custom agents
- Research Viewer: Display verified results
- Verification Panel: Review citations and evidence
- Audit Viewer: Inspect agent actions

**Session Integration:**
- Session D-Bus for local UI/runtime
- D-Bus API for agent control
- Notification integration

### 7.2 ContextGit Integration

**Runtime Context:**
- Per-agent context branches
- Context isolation between agents
- Context merge/rebase operations
- Context rollback

**From [ECOSYSTEM.md]:**
- Confirm headless runtime interface
- Non-repo session mode
- Per-child context branch isolation
- Branch/merge rollback proof

### 7.3 RepoSpine Integration

**System Context:**
- Multi-root system story
- Stable library or MCP path
- Freshness surfacing in UI
- Runtime packaging

**From [ECOSYSTEM.md]:**
- Context quality/latency on real workspace
- Runtime-packaging proof

### 7.4 ModelCheck Integration

**Model Promotion:**
- Gate for candidate models
- Evaluation against current default
- Attach reports to model changes
- Ollama support

**From [ECOSYSTEM.md]:**
- Add MIT license file
- Evaluation reproducibility
- Delta vs baseline on user workload

---

## 8. Implementation Phases

### Phase 7: AI-Native Layer Foundation

#### 7.1 Core Infrastructure (Month 1-2)
- [ ] assistantd daemon skeleton
- [ ] D-Bus integration (session/system)
- [ ] Basic policy engine
- [ ] Audit infrastructure (SQLite + Journal)
- [ ] Warden integration framework
- [ ] MCP protocol adapter

#### 7.2 Provider Router (Month 2-3)
- [ ] Provider adapter interface
- [ ] OpenAI adapter
- [ ] Ollama adapter (local)
- [ ] Fake provider for testing
- [ ] Provider selection logic
- [ ] Fallback handling

#### 7.3 Built-in Agents (Month 3-4)
- [ ] Research agent (read-only)
- [ ] Context agent (RepoSpine)
- [ ] Security agent (read-only)
- [ ] Performance agent (read-only)
- [ ] Agent registry
- [ ] Agent lifecycle management

#### 7.4 Sandbox Integration (Month 4-5)
- [ ] Warden sandbox profiles
- [ ] MCP worker sandboxing
- [ ] Policy-derived sandbox config
- [ ] Sandbox security tests
- [ ] Bypass matrix validation

### Phase 8: Advanced Capabilities

#### 8.1 Code & Automation Agents (Month 5-6)
- [ ] Code agent with sandboxed execution
- [ ] Automation agent with workflows
- [ ] Tool integration (git, build systems)
- [ ] Safety boundaries for code execution

#### 8.2 User Customization (Month 6-7)
- [ ] Agent definition parser (SKILL.md)
- [ ] Validation pipeline
- [ ] Approval workflow
- [ ] User agent registry
- [ ] Import/export with trust boundaries

#### 8.3 Routines & Scheduling (Month 7-8)
- [ ] Routine graph execution
- [ ] Time-based triggers
- [ ] Event-based triggers
- [ ] Routine validation
- [ ] Routine audit

### Phase 9: Production & Scale

#### 9.1 Optimization (Month 8-9)
- [ ] Multi-model optimization
- [ ] Cost tracking and budgeting
- [ ] Performance benchmarking
- [ ] Resource management

#### 9.2 Advanced Features (Month 9-10)
- [ ] Cross-device synchronization
- [ ] Collaboration features
- [ ] Enterprise deployment
- [ ] Advanced security features

---

## 9. Data Flow & APIs

### 9.1 D-Bus API

**Session Bus (org.axiom.AI):**
```
Interface: org.axiom.AI.Manager
Methods:
  - ListAgents() -> [AgentInfo]
  - GetAgent(agent_id: String) -> AgentInfo
  - Execute(agent_id: String, request: dict) -> RequestId
  - Cancel(request_id: String)
  - GetStatus(request_id: String) -> Status

Signals:
  - AgentRegistered(agent_id: String)
  - AgentRemoved(agent_id: String)
  - RequestStarted(request_id: String, agent_id: String)
  - RequestCompleted(request_id: String, result: dict)
  - RequestFailed(request_id: String, error: String)

Properties:
  - AvailableAgents: [String]
  - ActiveRequests: [RequestId]
```

**Agent Interface (org.axiom.AI.Agent):**
```
Interface: org.axiom.AI.Agent[agent_id]
Methods:
  - Execute(request: dict) -> Result
  - GetStatus() -> Status
  - GetCapabilities() -> [Capability]
  - Configure(config: dict)

Signals:
  - StatusChanged(new_status: String)
  - ProgressUpdate(progress: double, message: String)
  - ResultReady(result: dict)
  - ErrorOccurred(error: String)

Properties:
  - Name: String
  - Description: String
  - Version: String
  - Status: String
  - Capabilities: [Capability]
```

### 9.2 REST API (Optional, for external integration)

**Endpoint:** `http://localhost:8080/api/v1`

**Resources:**
- `GET /agents` - List available agents
- `GET /agents/{id}` - Get agent details
- `POST /agents/{id}/execute` - Execute agent
- `GET /requests/{id}` - Get request status
- `DELETE /requests/{id}` - Cancel request
- `GET /audit` - Query audit logs

### 9.3 File System Integration

**Configuration:**
- `~/.config/axiom/ai/` - User AI configuration
- `~/.config/axiom/ai/agents/` - User-defined agents (SKILL.md files)
- `~/.config/axiom/ai/registry/` - Registered agent metadata
- `~/.local/share/axiom/ai/` - Cache and local data

**System:**
- `/usr/share/axiom/ai/` - System agent definitions
- `/usr/lib/axiom/ai/` - Binaries and libraries
- `/var/lib/axiom/ai/` - System-wide data

---

## 10. Error Handling & Recovery

### 10.1 Error Classification

| Category | Severity | Example | Handling |
|----------|----------|---------|----------|
| InvalidArgument | Low | Malformed request | Reject with error |
| Unauthorized | Medium | Missing capability | Request auth or reject |
| ApprovalRequired | Medium | Sensitive operation | Prompt user |
| ExpiredGrant | Medium | Grant expired | Request re-auth |
| Unsupported | Low | Unknown capability | Reject with error |
| Cancelled | Low | User cancelled | Clean up |
| AuditUnavailable | High | Audit system down | Fail closed |
| VerificationFailed | Medium | Evidence missing | Flag and report |
| InternalError | High | Internal failure | Log, fail closed |
| RateLimited | Medium | Too many requests | Retry with backoff |
| Timeout | Medium | Operation timed out | Retry or fail |
| ProviderFailure | Medium | Provider unavailable | Fallback or fail |

### 10.2 Recovery Strategies

**Retry:**
- Network errors: 3 retries with exponential backoff
- Rate limits: Respect Retry-After header
- Timeouts: Retry once with increased timeout

**Fallback:**
- Provider failure: Try alternative provider
- Model failure: Try alternative model
- Agent failure: Escalate to parent

**Compensation:**
- Partial execution: Record state for manual review
- Failed verification: Flag for human review
- Security violation: Quarantine and alert

---

## 11. Performance Considerations

### 11.1 Performance Goals

| Metric | Target | Measurement |
|--------|--------|-------------|
| Agent spawn time | < 500ms | Cold start |
| Request processing | < 1s | Simple query |
| Research workflow | < 30s | 10-source verification |
| Memory overhead | < 100MB | Per agent |
| CPU overhead | < 10% | Idle system |

### 11.2 Optimization Techniques

**Caching:**
- Model responses (with validation)
- Web search results
- Document parsing
- Context caching (RepoSpine)

**Batching:**
- Multiple searches in parallel
- Document processing pipelines
- Agent coordination

**Lazy Loading:**
- Load models on demand
- Load tools when needed
- Load context just-in-time

---

## 12. Testing Strategy

### 12.1 Test Categories

**Unit Tests:**
- Policy engine validation
- Workflow graph execution
- Agent behavior
- Security checks

**Integration Tests:**
- End-to-end workflows
- Agent coordination
- MCP integration
- Warden sandboxing

**System Tests:**
- Multi-agent scenarios
- Load testing
- Failure injection
- Recovery testing

**Security Tests:**
- Penetration testing
- Sandbox escape attempts
- Prompt injection
- Authorization bypass

### 12.2 Test Automation

**CI Pipeline:**
1. Static analysis (code, schemas)
2. Unit tests
3. Integration tests
4. Security scans
5. Performance benchmarks
6. Regression tests

**QA Process:**
- Manual testing of critical paths
- User acceptance testing
- Security review
- Performance validation

---

## 13. Documentation Requirements

### 13.1 User Documentation

- Getting Started Guide
- Agent Reference (built-in agents)
- Custom Agent Tutorial
- Security Guide
- Troubleshooting Guide

### 13.2 Developer Documentation

- Architecture Overview (this document)
- API Reference
- Agent Development Guide
- Integration Guide
- Testing Guide

### 13.3 Internal Documentation

- Design Decisions (ADRs)
- Implementation Notes
- Security Analysis
- Performance Reports

---

## 14. Open Questions & Risks

### 14.1 Technical Risks

| Risk | Mitigation | Likelihood | Impact |
|------|------------|------------|--------|
| Warden bypass vulnerabilities | Independent security audit | Medium | High |
| Model hallucination in research | Multi-source verification | High | Medium |
| Performance overhead | Optimization, hardware acceleration | Medium | Medium |
| Complexity explosion | Modular design, clear boundaries | Medium | Medium |
| Integration issues | Early integration testing | Medium | Medium |

### 14.2 Resource Risks

| Risk | Mitigation | Likelihood | Impact |
|------|------------|------------|--------|
| Development time | Phased approach, priorities | Medium | Medium |
| Maintenance burden | Automation, documentation | Medium | Medium |
| Community adoption | User-friendly design, tutorials | Medium | Medium |

### 14.3 Security Risks

| Risk | Mitigation | Likelihood | Impact |
|------|------------|------------|--------|
| Sandbox escape | Defense in depth, monitoring | Low | High |
| Privilege escalation | Least privilege, capability model | Low | High |
| Data leakage | Encryption, access controls | Medium | High |
| Denial of service | Rate limiting, resource limits | Medium | Medium |

### 14.2 Open Questions

1. **Model Selection:** Which models to support initially?
   - Local: Ollama with which models?
   - Cloud: OpenAI, Anthropic, Google?

2. **Cost Management:** How to handle cloud provider costs?
   - User-provided keys only?
   - Built-in cost tracking?
   - Budget limits?

3. **Offline Operation:** How to handle offline scenarios?
   - Local models only?
   - Cached results?
   - Degraded functionality?

4. **Cross-Device Sync:** When to implement ContextGit?
   - Phase 7 or later?
   - Only for specific use cases?

5. **Enterprise Features:** What enterprise features are needed?
   - Centralized management?
   - Audit aggregation?
   - Policy enforcement?

---

## 15. Conclusion

This architecture specification defines **Jarvis 0.1** as a comprehensive AI-native layer for Axiom that:

1. **Learns from Siri's failures** by using orchestrated specialist agents instead of monolithic AI
2. **Builds on modern frameworks** like LangGraph and CrewAI while maintaining Axiom's security boundaries
3. **Enables deep research** with verifiable, cross-checked results
4. **Supports cross-domain capabilities** for coding, marketing, security, automation, and content creation
5. **Empowers users** to build custom agents with bounded capabilities
6. **Maintains security** through Warden sandboxing and capability-based authorization

The phased implementation approach ensures that we can deliver value incrementally while maintaining Axiom's high standards for security, reliability, and user experience.

**Next Steps:**
1. Review and refine this architecture
2. Resolve open questions
3. Begin Phase 7 implementation
4. Establish testing and validation processes

---

## Document Metadata

- **Status:** PROPOSAL
- **Version:** 0.2.0
- **Last Updated:** 2026-11-06
- **Author:** Axiom AI Architecture Team
- **Reviewers:** TBD
- **Approval Date:** TBD
- **Next Review:** 2026-11-20

---

## References

- [JARVIS_01_RESEARCH.md](JARVIS_01_RESEARCH.md) - Comprehensive research findings
- [AI_ARCHITECTURE.md](AI_ARCHITECTURE.md) - Axiom AI architecture
- [AGENT_SYSTEM.md](AGENT_SYSTEM.md) - Agent system design
- [SYSTEM_AGENT_API.md](SYSTEM_AGENT_API.md) - Capability contracts
- [ROUTINES.md](ROUTINES.md) - Deterministic routines
- [MCP.md](MCP.md) - MCP integration
- [ECOSYSTEM.md](ECOSYSTEM.md) - First-party ecosystem
- [WARDEN_INTEGRATION.md](../security/WARDEN_INTEGRATION.md) - Warden integration spec
