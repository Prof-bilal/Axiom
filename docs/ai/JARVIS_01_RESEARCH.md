# Jarvis 0.1: Deep Research & Multi-Domain AI Infrastructure

**Status:** RESEARCH DOCUMENT - Comprehensive Analysis for Axiom's AI-Native Layer  
**Author:** Axiom AI Research Team  
**Date:** 2026-11-06  
**Phase:** Pre-Phase 7 (AI-native layer) - Strategic Research  
**Version:** 0.1.0  

---

## Executive Summary

This document presents deep research findings for **Jarvis 0.1** — Axiom's proposed AI infrastructure that enables users to build customizable, domain-specific AI agents for deep research, cross-checking, coding, marketing, security, automation, and content creation. The research synthesizes lessons from Apple's Siri failures, analyzes modern AI agent frameworks, examines deep research infrastructure patterns, and proposes a unique architecture aligned with Axiom's existing AI contracts.

### Key Insights

1. **Siri's Failure Teaches Us:** Single monolithic agents fail; orchestrated specialist agents succeed
2. **Modern Frameworks Show:** LangGraph (durable state), CrewAI (role-based), Microsoft Agent Framework (enterprise) are production-ready
3. **Deep Research Requires:** Deterministic workflows, verifiable citations, cross-source validation
4. **Security is Non-Negotiable:** Warden/bubblewrap sandboxing + capability-based authorization
5. **User Customization:** Declarative agent definitions with bounded capabilities

---

## Table of Contents

1. [Apple Siri Failure Analysis](#1-apple-siri-failure-analysis)
2. [Modern AI Agent Framework Landscape](#2-modern-ai-agent-framework-landscape)
3. [Deep Research AI Infrastructure](#3-deep-research-ai-infrastructure)
4. [Cross-Domain AI Capabilities](#4-cross-domain-ai-capabilities)
5. [User-Customizable Agent Systems](#5-user-customizable-agent-systems)
6. [Security & Sandboxing Infrastructure](#6-security--sandboxing-infrastructure)
7. [MCP & Tool Integration](#7-mcp--tool-integration)
8. [Deterministic Routines & Workflows](#8-deterministic-routines--workflows)
9. [Jarvis 0.1 Architecture Proposal](#9-jarvis-01-architecture-proposal)
10. [Implementation Roadmap](#10-implementation-roadmap)
11. [Source Ledger](#11-source-ledger)

---

## 1. Apple Siri Failure Analysis

### What Went Wrong

#### 1.1 Architectural Failures

**Hybrid Architecture Problem** 
- Apple attempted to merge legacy command-based Siri with new LLM capabilities
- Craig Federighi admitted this hybrid approach "didn't work" [bE0uYDV7]
- Forced complete rebuild from scratch

**Strategy Indecision**
- Initial plan: Dual models "Mini Mouse" (local) + "Mighty Mouse" (cloud)
- Shifted to single cloud-based model
- Lack of clear technical direction earned team nickname "AIMLess" [ZFDTE0eC, w0Oglb27]

**Privacy vs. Capability Trade-off**
- Apple's strict privacy-first approach limited Siri's ability to learn from large datasets
- On-device processing prevented leveraging server-scale model training [9F0h0QBR, Icr5OnRi]
- Result: "lobotomised AI" that couldn't compete with Google Assistant's data-driven improvements

#### 1.2 Organizational Failures

**Poor Leadership**
- Multiple reports cite "overly relaxed culture" and "lack of ambition" [CbCAuYoE, w0Oglb27]
- AI/ML group passed Siri between teams like a "hot potato" [w0Oglb27]
- Tim Cook stripped AI chief John Giannandrea of Siri responsibility after delays [1mZuaKmP]

**Execution Problems**
- Nine months after promising new features, delays were "ugly and embarrassing" [1mZuaKmP]
- Focused on "small wins" (removing "hey" from "hey Siri") instead of substantial improvements [w0Oglb27]
- $250M settlement for undelivered AI innovations [9F0h0QBR]

#### 1.3 Technical Failures

**Hallucination in System Integration**
- Siri is deeply integrated into iOS system operations
- AI chatbot hallucinations pose real safety risks when connected to system controls [9F0h0QBR]

**Vendor Dependence**
- Apple signed $1B/year deal with Google to license Gemini as foundation [bE0uYDV7]
- Opening Siri to third-party AI (ChatGPT, Gemini, Claude) in iOS 27 [bE0uYDV7]

### Lessons for Jarvis 0.1

✅ **DO:**
- Use specialist agents with clear boundaries (coordinator layer routing to experts)
- Maintain capability-based authorization, never trust model output as authority
- Keep deterministic workflows separate from LLM reasoning
- Implement fail-closed security boundaries

❌ **DON'T:**
- Don't merge old command systems with new AI without clear contracts
- Don't let AI make authorization decisions
- Don't compromise security for capability
- Don't rely on single vendor or model

---

## 2. Modern AI Agent Framework Landscape

### 2.1 Framework Comparison Matrix

| Framework | Type | Strengths | Weaknesses | Best For | Production Ready |
|-----------|------|-----------|------------|----------|------------------|
| **LangGraph** | Graph-based | Stateful workflows, human-in-loop, audit trails | Complex setup | Production agents | ✅ Yes (0.4+) |
| **CrewAI** | Role-based | Fast prototyping, intuitive mental model | Limited fine-grained control | Multi-agent crews | ✅ Yes (0.105+) |
| **Microsoft Agent Framework** | Enterprise | Azure integration, responsible AI guardrails | Microsoft stack dependency | Enterprise teams | ✅ Yes (1.0 GA) |
| **AutoGen** | Conversational | Dynamic negotiation, research workflows | Maintenance mode | Conversational agents | ⚠️ Legacy |
| **OpenAI Agents SDK** | Vendor-specific | Native tool use, memory | OpenAI lock-in | OpenAI-first stacks | ✅ Yes |
| **Claude Agent SDK** | Vendor-specific | Memory, tracing | Claude lock-in | Claude deployments | ✅ Yes |
| **LangChain** | General-purpose | Broad integrations, provider swaps | Orchestration abstraction tax | Rapid prototyping | ✅ Yes |
| **LlamaIndex** | RAG-focused | Document workflows | Specialized | RAG-heavy systems | ✅ Yes |

**Sources:** [HKE5YDsL, HQwovGJ8, PQScGUYZ, QSQqEgS3, TadLr85Y, mUuo5a4B, j8J79a9E]

### 2.2 Framework Selection Guidance

**For Jarvis 0.1, consider:**

1. **LangGraph** for:
   - Durable stateful execution
   - Human-in-the-loop checkpoints
   - Audit trails and rollback points
   - Complex conditional logic
   - Production monitoring

2. **CrewAI** for:
   - Role-based agent crews
   - Fast prototyping
   - Research pipelines
   - Content systems
   - Planning-heavy workflows

3. **Custom Hybrid** for:
   - Axiom-specific contracts
   - Deterministic validation layers
   - Warden sandbox integration
   - Typed capability system

**Recommendation:** Build Axiom-native orchestration with LangGraph-inspired graph execution, CrewAI-inspired role definitions, but Axiom's own authorization and audit layers.

### 2.3 Key Patterns from Production Systems

**Conductor (Microsoft Open Source)**
- YAML-based deterministic workflows
- Isolated agents with explicit routing
- Cost control and auditability
- No LLM making routing decisions
- Multiple provider/model support

**Critical Insight:** "Orchestration should be deterministic and inspectable. Not an LLM making routing decisions." [Conductor Microsoft Blog]

**Hybrid Architecture Pattern:**
- Normal code controls workflow, permissions, states, validations, integrations
- AI handles classification, extraction, summarization, drafting, finding ambiguity
- Explicit review, exception, and audit paths connect both [sOUKa2au]

---

## 3. Deep Research AI Infrastructure

### 3.1 Research Assistant Requirements

**Core Capabilities:**
- Multi-source verification (minimum 2 sources per claim)
- Cross-referencing contradictory information
- Pattern identification across documents
- Structured evidence with verifiable citations
- Human-in-the-loop validation

**Infrastructure Components:**

1. **Source Verification Layer**
   - Scite: Every claim links to specific sentence in source paper [ywSyTKkT]
   - Atlas: Work across papers with passage-level citations [WWk4NYaE]
   - Parallel: Structured JSON with verifiable citations [pcknhaxB]

2. **Cross-Checking Engine**
   - Automated contradiction detection
   - Unsupported claim tagging
   - Confidence level annotation
   - Evidence traceability [tHpwjRac]

3. **Deep Research Protocol**
   - Open 50+ browser tabs simultaneously
   - Read contradicting sources
   - Cross-reference data
   - Verify claims [x6axvjdS]
   - Human "smell test" for final synthesis

**Key Insight:** "Even the most advanced deep research AI protocol requires a human 'smell test' to ensure final synthesis is truly reliable." [x6axvjdS]

### 3.2 Research Workflow Phases

| Phase | Tool | Purpose | Verification |
|-------|------|---------|--------------|
| Discovery | Semantic Scholar, Research Rabbit | Find relevant papers | Source existence check |
| Screening | Elicit | Extract key information | Table-based validation |
| Extraction | Atlas | Deep reading, questioning | Passage-level citation |
| Verification | Scite | Check citation support | Smart Citations |
| Synthesis | Custom | Combine findings | Human review |

**Source:** [WWk4NYaE]

### 3.3 Implementation Patterns

**For Jarvis 0.1 Research Agents:**

1. **Citation Per Claim** (not per paragraph)
   - Attach source to sentence carrying assertion
   - Don't use trailing "Sources: [1][2][3]" [1RbN4ivn]

2. **Verifiable Evidence**
   - Every answer grounded in real papers
   - Never generated or hallucinated [ywSyTKkT]

3. **Cross-System Questions**
   - Combine database numbers, support tickets, CRM notes, team documentation
   - Currently gets answered worst because requires manual reconciliation [1RbN4ivn]

---

## 4. Cross-Domain AI Capabilities

### 4.1 Domain-Specific Agents

#### Coding Agents
- **AutonomousFix (Cycode):** Agents that reason, remediate, open PR-ready fixes
- **Context:** Maestros orchestrate purpose-built agents [boy0oIk9]
- **Security:** Guardrails at point of creation, not after
- **Verification:** Code runs, outputs compared against known values [vDa8hsy2]

#### Marketing Agents
- **Composio:** Action infrastructure for 1,000+ business systems
- **Capabilities:** 50,000+ agent-ready tools, 1M+ connected accounts
- **Managed Auth:** Automatic token refresh, encrypted credential store
- **Use Case:** Content marketing automation [0Oi13gjt]

#### Security Agents
- **Snyk:** Secures code AI writes, agents it runs, apps it builds
- **Focus:** AI-generated code security, full-stack protection [pBELw75d]
- **Auth0:** Essential practices for AI-generated code security [r9u3bYEz]

#### Content Creation Agents
- **HubSpot:** AI website generator, content writer, no-code customization
- **Capability:** Emails, landing pages, blogs, social media [ixRwBDh9]
- **No-Code:** AI platforms for non-technical creators [vDa8hsy2]

### 4.2 Cross-Domain Integration Patterns

**Composio Pattern:**
- One SDK to act across 1,000+ business systems
- Self-learning improves repeat task accuracy by 30% on 2x fewer tokens
- Managed auth handles credential complexity [0Oi13gjt]

**Key Insight:** "You don't have a content creation problem. You have a copy-paste problem." [0Oi13gjt]

**Gumloop Pattern:**
- Connect any LLM to internal tools without code
- Continuous AI agents for real-time data processing
- Sales, research, admin task automation [BBZqbf8E]

---

## 5. User-Customizable Agent Systems

### 5.1 Customization Approaches

#### No-Code Platforms
- **MindStudio:** Design, build, deploy agents without coding
- **Features:** Schedule agents, host under own domain, white-label
- **Use Cases:** Voice assistants, social media, transactional messages [GuNytlOD]

- **MindPal:** Free no-code AI agent builder
- **Capability:** Create custom agents in minutes, multi-agent workflows
- **Trusted by:** 50k+ businesses [A9CyCegt]

#### Pro-Code Frameworks
- **AutoGen:** Extensible pluggable components
- **Customization:** Fully bespoke agentic system experiences
- **Pattern:** Abstract tools, modularize functionality, toggle features [NsNRdEUi]

#### Hybrid Approach (Recommended)
**Personal AI Assistant Pattern:**
- Abstract tools and modularize functionality
- Allow features to be turned on/off
- Shape assistant around user workflows [2tLPolaN]
- Open-source for community adaptation

### 5.2 Customization Constraints

**Security Constraints:**
- No scripts, no shell, no absolute paths
- No embedded secrets
- Declarative metadata + prompt only (Skill-style frontmatter)

**Capability Constraints:**
- User child can only use capabilities user already holds
- Approval per-capability, revocable
- Schema validation, purpose-collision check
- Imported/shared children are untrusted input

**Source:** Axiom [AGENT_SYSTEM.md](#user-authored-child-agents)

---

## 6. Security & Sandboxing Infrastructure

### 6.1 Sandboxing Technologies

#### Bubblewrap (bwrap)
- **Type:** Low-level unprivileged sandboxing tool
- **Used by:** Flatpak, CI runners, build systems, AI agent harnesses
- **Features:**
  - User namespace-based sandboxing
  - No root required, no daemon, no setuid binary
  - Assembles sandbox via syscalls, then execs into command
  - Handles filesystem construction, UID/GID mapping, PID 1 semantics
- **Use Case:** Execute untrusted code locally [McA8BM18, 7FsOPoO8, KTe85wB9]

**Bubblewrap Security Model:**
- Protection level determined by command-line arguments
- Framework responsible for defining security model
- Use cases: security boundary vs filesystem layout change [7FsOPoO8]

#### OpenCode Sandboxing
- **Pattern:** Kernel isolation with restrictiveness lattices
- **Technologies:** Bubblewrap, gVisor, Seatbelt
- **Principle:** Merge always moves outward — agents can escalate isolation, never downgrade
- **Policy:** Global floor prevents sandbox: "none" even if requested [0Eub9Sjx]

### 6.2 Warden Integration

**Current Warden State (from Axiom docs):**
- Runs MCP servers in OS-native sandbox
- Linux backend: bubblewrap namespaces + setpriv no_new_privs + strace
- Host-side HTTP(S)-only egress proxy with hostname allowlist
- Deny-by-default bind-mount visibility (ENOENT)
- Env allowlisting, wall-clock/memory limits, JSONL audit
- No seccomp filter, no Landlock, no typed programmatic interface
- Self-reports: NOT hardened against determined local attacker

**Warden for Axiom:**
- Must become layer every agent/tool execution passes through
- Policy derived from approved typed request
- Warden NEVER authorizes
- Needs bypass matrix on mainline/LTS

**Source:** [ECOSYSTEM.md](#warden---the-security-answer)

### 6.3 Sandboxing Best Practices

1. **Never trust model-generated sandbox policies**
2. **Always use capability-based authorization**
3. **Fail closed on security violations**
4. **Maintain audit trails for all sandboxed operations**
5. **Test sandbox escape scenarios**

---

## 7. MCP & Tool Integration

### 7.1 MCP Current State

**From Axiom docs:**
- Protocol: 2026-07-28 specification
- Status: RESEARCH until bounded capability execution works
- Integration requires: owner, purpose, pinned version, transport, auth, tools, schemas, resource scopes, network destinations, sandbox prerequisites, data retention, audit events, timeout/output limits, adversarial tests
- Tool descriptions, resources, results are UNTRUSTED CONTENT
- Cannot rewrite policy

**Security Requirements:**
- Local stdio only for reviewed executable identities
- No home, system bus, SSH/GPG agents, or provider keys ambiently
- HTTP: implement authorization requirements, validate intended resource/audience
- Never pass token for another service through to server
- No unauthenticated listeners beyond loopback

**Source:** [MCP.md](MCP.md)

### 7.2 MCP Integration Strategy

**For Jarvis 0.1:**
- MCP workers run under Warden sandbox
- Each MCP server has explicit capability declaration
- Tool schemas validated against Axiom contracts
- Network destinations allowlisted
- All MCP output treated as untrusted
- Audit every MCP tool invocation

**Integration Pattern:**
```
User Request → Parent Orchestrator → Policy Validation → 
MCP Worker (Warden Sandbox) → Tool Execution → 
Result Validation → Audit → Return to User
```

---

## 8. Deterministic Routines & Workflows

### 8.1 Axiom's Existing Contract

**From [ROUTINES.md]:**
- Natural language may generate routine draft ONCE
- Execution uses versioned declarative graph of approved capabilities
- Bounded arguments, dependencies, deadlines, failure policy
- NO embedded shell, arbitrary JavaScript, dynamic tool names, model-generated approval

**Required Record:**
- Routine ID/version, owner, readable description
- Trigger, graph, capability versions, resource scopes
- Expected external destinations, permission requirements
- Concurrency policy, audit retention

### 8.2 Workflow Patterns

**Conductor Pattern (Recommended):**
- YAML workflows with explicit routing
- Isolated agents
- Deterministic execution paths
- Cost control and auditability
- Multiple provider/model support

**Hybrid Pattern:**
- Deterministic code for permissions, states, calculations, validations, integrations
- AI for classification, extraction, summarization, drafting, finding ambiguity
- Explicit review, exception, audit paths

---

## 9. Jarvis 0.1 Architecture Proposal

### 9.1 Core Principles

1. **One Parent, Many Children** (from Axiom [AGENT_SYSTEM.md])
   - Single orchestrator (assistantd) owns planning, provider selection, delegation
   - Children are workers, not peers
   - No second orchestrator

2. **Bounded and Ephemeral Children**
   - Every child has capability allowlist, context scope, resource/time/step budget
   - Child runs out of budget → stops (no silent re-plan)

3. **Authority Never Grows**
   - Parent cannot grant child more than parent holds
   - Child cannot self-authorize
   - Child proposals re-enter parent → policy → executor path

4. **Model Output is Never Authority**
   - Child output is proposal, not authorization
   - Only deterministic validator + policy engine produce typed requests

### 9.2 Proposed Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        JARVIS 0.1                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│  │   Parent    │    │   Router    │    │   Policy    │      │
│  │ Orchestrator│───▶│  (Provider) │───▶│  Engine     │      │
│  │ (assistantd)│    │             │    │             │      │
│  └─────────────┘    └─────────────┘    └─────────────┘      │
│           │                   │                  │            │
│           ▼                   ▼                  ▼            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Child Registry                      │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  │   │
│  │  │Research │  │  Code   │  │Marketing│  │Security │  │   │
│  │  │ Agent   │  │ Agent   │  │ Agent   │  │ Agent   │  │   │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘  │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐              │   │
│  │  │ User    │  │Custom   │  │Custom   │              │   │
│  │  │ Agent   │  │ Agent 1 │  │ Agent 2 │              │   │
│  │  └─────────┘  └─────────┘  └─────────┘              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  Sandbox Layer (Warden)                │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  MCP Workers │ Tools │ External Services      │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │               Deterministic Executor                   │   │
│  │  (system-agentd for privileged, user executor for     │   │
│  │   unprivileged)                                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                     Audit Layer                         │   │
│  │  Session D-Bus │ System D-Bus │ SQLite │ Journal     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 9.3 Built-in Agent Catalogue (Proposed)

| # | Child | Purpose | Default Class | Sandbox | Status |
|---|-------|---------|---------------|---------|--------|
| 1 | **Research** | Deep research with verification, cross-checking | OBSERVE | none | Phase 7 |
| 2 | **Code** | Coding assistance, review, debugging | NORMAL | required | Phase 7 |
| 3 | **Marketing** | Content creation, campaign analysis | NORMAL | none | Phase 7 |
| 4 | **Security** | Adversarial review, vulnerability scanning | OBSERVE | required | Phase 7 |
| 5 | **Automation** | Workflow automation, task orchestration | SENSITIVE | required | Phase 7 |
| 6 | **Content** | Multi-modal content creation | NORMAL | none | Phase 7 |
| 7 | **Data** | Analytics, insights, visualization | OBSERVE | none | Phase 7 |
| 8 | **User** | Custom user-defined agents | NORMAL+ | varies | Phase 8 |

### 9.4 User Agent Definition (SKILL.md Format)

```markdown
---
name: my-research-agent
type: child-agent
version: 0.1.0
purpose: Deep research on AI infrastructure
author: user@axiom
---

## Capabilities
- research.web_search
- research.document_analysis
- research.cross_verification
- tools.context_read

## Tools
- web_search: {max_results: 10, timeout: 30s}
- document_parser: {max_size: 10MB}
- citation_validator: {sources: 3}

## Model Binding
- provider: local (ollama)
- model: llama3.2:11b
- fallback: cloud (openai:gpt-4o)

## Context Scope
- repospine: [project-root]
- contextgit: research-branch

## Sandbox
- profile: research-profile
- network: allowlist [api.scite.ai, semantic.scholar, ...]

## Budget
- max_steps: 20
- wall_time: 10m
- tokens: 10000
- cost: $1.00

## Evidence
- Must return: citations, confidence_scores, contradiction_flags
- Verification: cross-check minimum 2 sources

## Failure Policy
- On budget exhausted: stop and report
- On verification failure: flag and escalate to parent
- On network error: retry x3 then fail
```

### 9.5 Request Lifecycle

```
1. User Request → Overlay UI
2. Intent Resolution → Bounded Plan
3. Capability Matching → Select Child Agent(s)
4. Policy Validation → Check capabilities, scope, budget
5. Authorization → User approval for sensitive operations
6. Sandbox Setup → Warden with policy-derived constraints
7. Execution → Child agent runs within bounds
8. Validation → Verify results against policy
9. Audit → Record all steps and outcomes
10. Return → Formatted response to user
```

---

## 10. Implementation Roadmap

### Phase 7: AI-Native Layer (Target: Q1 2027)

#### Milestone 7.1: Foundation
- [ ] Parent orchestrator (assistantd) skeleton
- [ ] Provider router with one cloud + Ollama adapter
- [ ] Policy engine with capability validation
- [ ] Basic audit infrastructure
- [ ] MCP integration framework

#### Milestone 7.2: Read-Only Agents
- [ ] Research agent with web search and verification
- [ ] Security agent for adversarial review
- [ ] Performance agent for system monitoring
- [ ] Context agent (RepoSpine integration)

#### Milestone 7.3: Sandboxed Agents
- [ ] Warden integration with policy-derived sandboxing
- [ ] Code agent with bounded execution
- [ ] Automation agent with workflow orchestration
- [ ] Bypass matrix validation

### Phase 8: Advanced Capabilities (Target: Q2 2027)

#### Milestone 8.1: Reversible State Agents
- [ ] Dependency agent for package management
- [ ] Customization agent (Morphix integration)
- [ ] Rollback verification

#### Milestone 8.2: User-Customizable Agents
- [ ] Agent registry with validation
- [ ] Declarative agent definitions (SKILL.md format)
- [ ] Approval workflow for user agents
- [ ] Sharing/import with trust boundaries

#### Milestone 8.3: Deterministic Routines
- [ ] Routine graph execution engine
- [ ] Versioned routine storage
- [ ] Routine validation and approval
- [ ] Routine audit and rollback

### Phase 9+: Production & Scale (Target: Q3 2027+)

- [ ] Multi-model optimization
- [ ] Cost tracking and budgeting
- [ ] Performance benchmarking
- [ ] Cross-device synchronization (ContextGit)
- [ ] Enterprise deployment options

---

## 11. Source Ledger

### Apple Siri Analysis
- [1mZuaKmP] Yahoo Tech - "Siri, explain how you became Apple's most embarrassing failure" - https://tech.yahoo.com/articles/siri-explain-became-apple-most-120000581.html
- [9F0h0QBR] Yahoo News UK - "4 Reasons Why Apple Has Failed With Siri" - https://uk.news.yahoo.com/4-reasons-why-apple-failed-153723720.html
- [CbCAuYoE] Reddit r/apple - "Report Reveals Internal Chaos Behind Apple's Siri Failure" - https://www.reddit.com/r/apple/comments/1jvzmhq/
- [Icr5OnRi] Tommo.fyi - "Apple's 15-Year AI Failure: Siri's Promise vs Reality" - https://www.tommo.fyi/apples-15-year-ai-odyssey/
- [U5zIc1qS] Medium Mac O'Clock - "iOS 27 Siri AI: Why Siri Failed for a Decade" - https://medium.com/macoclock/siri-was-useless-for-ten-years-ios-27-finally-explains-the-bottleneck-ea6b31af18d6
- [ZFDTE0eC] Technowize - "The Apple Siri AI Failure Explained" - https://www.technowize.com/the-apple-siri-ai-failure-explained-what-went-wrong-what-happens-next/
- [bE0uYDV7] GetRush.ai - "The Siri Trap: Why Single-Agent Assistants Always Fail" - https://getrush.ai/blog/the-siri-trap
- [w0Oglb27] MacRumors - "Report Reveals Internal Chaos Behind Apple's Siri Failure" - https://www.macrumors.com/2025/04/10/chaos-behind-siri-revealed/

### AI Agent Frameworks
- [HKE5YDsL] Cordum.io - "AI Agent Frameworks 2026: LangGraph vs CrewAI..." - https://cordum.io/blog/ai-agent-frameworks-comparison
- [HQwovGJ8] Pecollective - "AI Agent Frameworks Compared: LangGraph, CrewAI, AutoGen" - https://pecollective.com/blog/ai-agent-frameworks-compared
- [PQScGUYZ] LangChain - "The best AI agent frameworks in 2026" - https://www.langchain.com/resources/ai-agent-frameworks
- [QSQqEgS3] Gurusup - "Best Multi-Agent Frameworks in 2026" - https://gurusup.com/blog/best-multi-agent-frameworks-2026
- [TadLr85Y] Ayautomate - "Multi-Agent Frameworks 2026: 12 Best for Orchestration" - https://www.ayautomate.com/blog/best-multi-agent-frameworks
- [j8J79a9E] Medium ATNO - "10 AI Agent Frameworks You Should Know in 2026" - https://medium.com/@atnoforgenai/10-ai-agent-frameworks-you-should-know-in-2026
- [mUuo5a4B] Medium - "Top 9 AI Agent Frameworks in 2026" - https://medium.com/@iimoyjv0493b/top-9-ai-agent-frameworks-in-2026
- [sOUKa2au] DEV Community - "AI Workflow Automation: What Should Stay Deterministic" - https://dev.to/nxthatch_technologies/ai-workflow-automation

### Deep Research Infrastructure
- [1RbN4ivn] Skopx - "AI Research Assistants: Getting Cited Answers" - https://skopx.com/resources/ai-research-assistant-for-work
- [LD8hdpnU] Thomson Reuters - "What is Deep Research and AI for complex legal work?" - https://legal.thomsonreuters.com/blog/what-is-deep-research-the-ai-research-assistant-that-thinks-like-a-legal-expert
- [RgsJm5jv] MindStudio - "9 AI Agents for Research and Analysis" - https://www.mindstudio.ai/blog/ai-agents-research-analysis
- [WWk4NYaE] Atlas Workspace - "7 Best AI Research Assistants (2026)" - https://www.atlasworkspace.ai/blog/best-ai-research-assistants
- [pcknhaxB] Parallel - "What is deep research? Plan, search, report" - https://parallel.ai/articles/what-is-deep-research
- [tHpwjRac] Postellite - "Build an AI Research Assistant That Knows Your Business" - https://www.postellite.com/resources/guide/build-ai-research-assistant
- [x6axvjdS] ZeroSkill AI - "The 2026 Deep Research AI Protocol" - https://zeroskillai.com/deep-research-ai-protocol-2026/
- [vdOdhA8O] Arxiv - "Autonomous Research Agents: A Survey" - https://arxiv.org/html/2608.05179v1

### Cross-Domain AI
- [0Oi13gjt] Composio - "AI for content marketing" - https://composio.dev/content/ai-for-content-marketing-what-you-can-automate-today
- [B4DAfk6H] Demandbase - "16 Best AI Marketing Tools for B2B Success in 2026" - https://www.demandbase.com/blog/best-ai-tools-b2b-marketing
- [BBZqbf8E] Marketer Milk - "30 best AI marketing tools I'm using in 2026" - https://www.marketermilk.com/blog/ai-marketing-tools
- [boy0oIk9] Cycode - "Agentic Development Security Platform" - https://cycode.com/
- [ixRwBDh9] Nextiny Marketing - "30+ AI & No-Code Marketing Tools in 2026" - https://blog.nextinymarketing.com/no-code-ai-marketing-tools
- [pBELw75d] Snyk - "Secure Code, Agents & Apps" - https://snyk.io/
- [r9u3bYEz] Auth0 - "Generate More Secure Code With AI-Powered Tools" - https://auth0.com/blog/prompt-engineering-security/
- [vDa8hsy2] MyContent - "AI and Content Creation: Privacy-Sensitive Strategies" - https://mycontent.cloud/artificial-intelligence-and-content-creation-navigating-the
- [xY6Sudae] Ability.ai - "AI content engine: automating marketing without shadow AI" - https://www.ability.ai/blog/ai-content-engine-marketing

### User-Customizable Agents
- [08VOiVbQ] IBM - "How to Build an AI Agent" - https://www.ibm.com/think/topics/how-to-build-an-ai-agent
- [2tLPolaN] Towards Data Science - "Building a Personal AI Agent" - https://towardsdatascience.com/building-a-personal-ai-agent-in-a-couple-of-hours
- [6xwogBDs] DEV Community - "How to Build a Personal AI Assistant" - https://dev.to/-abdullah-sheikh/how-to-build-a-personal-ai-assistant-using-open-source-tools-4873
- [8YN3xXr2] Reddit r/AI_Agents - "My guide on what tools to use to build AI agents" - https://www.reddit.com/r/AI_Agents/comments/1il8b1i/
- [A9CyCegt] MindPal - "Free AI Agent Builder" - https://mindpal.space/tool/ai-agent-builder
- [BybsFcuU] Medium Jason Cyr - "Building a Personal AI Agent" - https://jasoncyr.medium.com/building-a-personal-ai-agent-from-zero-code-to-autonomous-system-e0201529e17
- [GMg4X7An] Aimultiple - "Building Personal AI Agents + 18 Agent Platforms" - https://aimultiple.com/personal-ai-agents
- [GuNytlOD] MindStudio - "Build powerful AI agents" - https://www.mindstudio.ai/
- [NsNRdEUi] GetStream - "Best 5 Frameworks To Build Multi-Agent AI Applications" - https://getstream.io/blog/multiagent-ai-frameworks/
- [ryvnZGCy] DEV Community - "How to Develop a Custom AI Agent from Scratch" - https://dev.to/albert_ed/how-to-develop-a-custom-ai-agent-from-scratch-tools-and-steps-3epg

### Security & Sandboxing
- [0Eub9Sjx] DEV Community - "OS-Level Sandboxing: Kernel Isolation for AI Agents" - https://dev.to/uenyioha/os-level-sandboxing-kernel-isolation-for-ai-agents-3fdg
- [0x9dalOU] Hacker News - "Sandboxing AI Agents in Linux" - https://news.ycombinator.com/item?id=46874139
- [7FsOPoO8] GitHub - "containers/bubblewrap" - https://github.com/containers/bubblewrap
- [KTe85wB9] Guillaume A - "Sandboxing OpenCode with Bubblewrap and Sandbox Runtime" - https://blog.guillaumea.fr/post/sandboxing-opencode-ai-agents-bubblewrap-srt
- [McA8BM18] Medium Siddhant Tiwary - "Sandboxing untrusted code with Bubblewrap" - https://siddhanttiwary.medium.com/sandboxing-untrusted-code-with-bubblewrap-52ab55d113b1

### Axiom Internal References
- [AGENT_SYSTEM.md] - Agent system design and child contracts
- [AI_ARCHITECTURE.md] - AI architecture and request lifecycle
- [SYSTEM_AGENT_API.md] - Typed capability contracts
- [MCP.md] - MCP integration requirements
- [ROUTINES.md] - Deterministic routines design
- [ECOSYSTEM.md] - First-party ecosystem mapping

---

## Conclusion

Jarvis 0.1 represents a unique opportunity to build an AI infrastructure that learns from Siri's failures and leverages modern agent frameworks while maintaining Axiom's strict security and authorization boundaries. By implementing:

1. **Orchestrated specialist agents** instead of monolithic AI
2. **Deterministic workflows** with AI as assistive, not authoritative
3. **Strong sandboxing** via Warden/bubblewrap
4. **Verifiable research** with cross-source validation
5. **User customization** with bounded capabilities

Axiom can deliver a truly unique and strong AI infrastructure that empowers users across coding, marketing, security, automation, content creation, and deep research domains.

**Next Steps:**
1. Review and approve this research document
2. Begin Phase 7 implementation with parent orchestrator
3. Develop capability-based policy engine
4. Integrate Warden sandboxing
5. Build first read-only agents (research, security, context)

---

**Document Status:** RESEARCH COMPLETE - Ready for team review and architecture decisions  
**Last Updated:** 2026-11-06  
**Next Review:** 2026-11-13
