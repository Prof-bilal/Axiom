# OpenJarvis: Technical Analysis for Jarvis 0.1

**Status:** TECHNICAL ANALYSIS  
**Author:** Axiom AI Research Team  
**Date:** 2026-11-06  
**Version:** 1.0.0  
**Purpose:** Deep technical analysis of OpenJarvis to inform Jarvis 0.1 architecture decisions  

---

## Executive Summary

OpenJarvis is a **research-grade framework for local-first personal AI** developed by Stanford SAIL's Hazy Research and Scaling Intelligence Lab. It represents the **state-of-the-art in on-device AI agent frameworks** and provides valuable architectural patterns for **Jarvis 0.1**. However, OpenJarvis has different design goals (research platform vs production desktop) that create opportunities for Jarvis 0.1 to differentiate.

### Key Findings

| Aspect | OpenJarvis | Jarvis 0.1 Opportunity |
|--------|------------|------------------------|
| **Primary Focus** | Research platform, local-first AI | Production desktop integration, Axiom-native |
| **Platform** | macOS, Linux, WSL2, Windows | Linux-native (Axiom), optimized for Wayland |
| **Architecture** | Modular agents, skills system | Orchestrated specialists with Axiom contracts |
| **Security** | Basic (local execution) | Enterprise-grade (Warden sandboxing) |
| **Extensibility** | Skills, plugins | MCP integration, SKILL.md agents |
| **Target** | Researchers, developers | Axiom desktop users, developers |
| **License** | Apache 2.0 | Axiom ecosystem |
| **Integration** | Standalone application | Deep OS integration (D-Bus, RepoSpine) |

**Strategic Conclusion:** OpenJarvis is a **complementary project, not a competitor**. Jarvis 0.1 should **adopt OpenJarvis's architectural patterns** (modular agents, local-first, skills) while **adding Axiom-specific features** (Warden sandboxing, D-Bus integration, capability-based auth, deterministic workflows).

---

## 1. Project Overview

### 1.1 What is OpenJarvis?

From official documentation:

> **"Personal AI, On Personal Devices"**

> **"OpenJarvis is a framework for local-first personal AI, built around three core ideas: shared primitives for building on-device agents; evaluations that treat energy, FLOPs, latency, and dollar cost as first-class constraints alongside accuracy; and a learning loop that improves models using local trace data."**

### 1.2 Project Background

- **Developed by:** Hazy Research and Scaling Intelligence Lab at Stanford SAIL
- **Research Initiative:** Intelligence Per Watt (studying intelligence efficiency of AI systems)
- **Paper:** arXiv:2605.17172 (May 2026)
- **Citation:** Saad-Falcon et al., "OpenJarvis: Personal AI, On Personal Devices"
- **Website:** https://openjarvis.stanford.edu/
- **Documentation:** https://open-jarvis.github.io/OpenJarvis/
- **Repository:** https://github.com/open-jarvis/OpenJarvis

### 1.3 Statistics (as of 2026-11-06)

- **Stars:** 13,579
- **Forks:** 3,255
- **License:** Apache License 2.0
- **Language:** Python (primary)
- **Created:** February 15, 2026
- **Last Update:** November 6, 2026 (active development)
- **Open Issues:** 112
- **Contributors:** 200+ (estimated)

---

## 2. Core Principles

### 2.1 Three Pillars of OpenJarvis

#### 1. Shared Primitives
- **Common building blocks** for on-device agents
- **Reusable components** for tool use, memory, retrieval
- **Standardized interfaces** between agents and tools
- **Example:** Unified tool calling interface across all agents

#### 2. Intelligence Efficiency
- **Treat energy, FLOPs, latency, dollar cost as first-class constraints**
- **Not just accuracy** - optimize for efficiency
- **Research finding:** Local models handle 88.7% of single-turn queries
- **Improvement:** 5.3× intelligence efficiency improvement from 2023-2025

#### 3. Learning Loop
- **Improve models using local trace data**
- **On-device fine-tuning** capabilities
- **Trace-based optimization** from real usage
- **Goal:** Continuous improvement without cloud dependency

### 2.2 Design Philosophy

> **"The goal is simple: make it possible to build personal AI agents that run locally by default, calling the cloud only when truly necessary."**

**Key Design Decisions:**
1. **Local-first:** Run on personal devices, cloud is optional
2. **Modular:** Agents, tools, and skills are composable
3. **Efficient:** Optimize for resource constraints
4. **Extensible:** Plugin architecture for new capabilities
5. **Research-focused:** Built for experimentation and benchmarking

---

## 3. Architecture

### 3.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenJarvis Framework                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Agents    │    │   Skills    │    │    Tools        │  │
│  │             │    │             │    │                 │  │
│  │ - morning   │    │ - hermes    │    │ - file I/O     │  │
│  │ - deep      │    │ - openclaw  │    │ - shell        │  │
│  │ - research  │    │ - custom    │    │ - web search   │  │
│  │ - code      │    │              │    │ - email        │  │
│  │ - ...       │    │              │    │ - calendar     │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│           │                   │                  │            │
│           └───────────────────┼──────────────────┘            │
│                               ▼                                  │
│                    ┌─────────────────┐                         │
│                    │    Executor     │                         │
│                    │  (Local/Cloud) │                         │
│                    └─────────────────┘                         │
│                               │                                  │
│                               ▼                                  │
│                    ┌─────────────────┐                         │
│                    │   Configuration  │                         │
│                    │   (YAML/JSON)   │                         │
│                    └─────────────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Component Details

#### 3.2.1 Agents

OpenJarvis ships with **8 built-in agents** across **3 execution modes**:

| Agent | Type | Description | Use Case |
|-------|------|-------------|----------|
| `morning_digest` | Scheduled | Daily briefing from email, calendar, health, news | Personal productivity |
| `deep_research` | On-demand | Multi-hop research with citations across web and local docs | Research assistance |
| `monitor_operative` | Continuous | Long-horizon monitoring with memory, compression, retrieval | System monitoring |
| `orchestrator` | On-demand | Multi-turn reasoning with automatic tool selection | Complex queries |
| `native_react` | On-demand | ReAct (Thought-Action-Observation) loop agent | Step-by-step reasoning |
| `operative` | Continuous | Persistent autonomous agent with state management | Long-running tasks |
| `native_openhands` | On-demand | CodeAct — generates and executes Python code | Code assistance |
| `simple` | On-demand | Single-turn chat, no tools | Lightweight conversation |

**Execution Modes:**
- **On-demand:** Run when explicitly called
- **Scheduled:** Run on a schedule (e.g., daily briefing)
- **Continuous:** Run persistently in background

#### 3.2.2 Skills

**Definition:** Skills teach agents how to better use tools and improve their reasoning.

**Key Properties:**
- Every skill is a tool
- Agents discover skills from a catalog
- Agents invoke skills on demand
- Skills can be optimized from trace history

**Supported Skill Sources:**
- [Hermes Agent](https://github.com/NousResearch/hermes-agent) (~150 skills)
- [OpenClaw](https://github.com/openclaw/skills) (~13,700 community skills)
- Any GitHub repository following the [agentskills.io](https://agentskills.io/specification) standard

**Example Skills:**
- `hermes:arxiv` - Search and retrieve arXiv papers
- `hermes:research` - Deep research capabilities
- `code-explainer` - Explain Python code
- Custom skills from any source

#### 3.2.3 Tools

**Built-in Tools:**
- File I/O (read/write files)
- Shell access (execute commands)
- Web search (via various providers)
- Email integration
- Calendar integration
- Health data integration
- News aggregation

**Tool Integration:**
- Tools are connected via adapters
- Unified interface across all tools
- Can be used by any agent
- Can be extended with custom tools

#### 3.2.4 Executor

**Local Execution:**
- Runs on user's hardware
- Uses local models (via Ollama)
- Supports multiple model providers
- Optimized for efficiency

**Cloud Execution:**
- Optional cloud-based processing
- Used when local resources insufficient
- Multiple cloud providers supported
- Cost tracking and optimization

### 3.3 Configuration System

**Presets:** Pre-configured agent setups for common use cases

| Preset | Description | Use Case |
|--------|-------------|----------|
| `morning-digest-mac` | Spoken daily briefing | macOS users |
| `morning-digest-linux` | Spoken daily briefing | Linux users |
| `morning-digest-minimal` | Text-only daily briefing | Minimal setup |
| `deep-research` | Multi-hop research agent | Research tasks |
| `code-assistant` | Code execution, file I/O, shell | Development |
| `scheduled-monitor` | Stateful agent on a schedule | Monitoring |
| `chat-simple` | Lightweight conversation | Simple queries |

**Configuration Files:**
- YAML-based configuration
- Agent definitions
- Tool configurations
- Skill mappings
- Model settings

---

## 4. Technical Implementation

### 4.1 Installation

**One-Command Install:**
```bash
# macOS / Linux / WSL2
curl -fsSL https://openjarvis.github.io/OpenJarvis/install.sh | bash

# Native Windows
irm https://openjarvis.github.io/OpenJarvis/install.ps1 | iex

# Desktop GUI
# Download .exe / .dmg / .deb / .rpm / .AppImage from releases
```

**Installation Process:**
1. Download and install `uv` (Python package manager)
2. Create Python virtual environment
3. Install Ollama (for local models)
4. Download starter model
5. Install OpenJarvis package
6. Background downloads: Rust extension, larger models

**Verification:**
```bash
jarvis doctor  # Check installation status
```

### 4.2 Usage

**Basic Commands:**
```bash
jarvis                          # Start chatting (default: chat-simple)
jarvis gui                      # Start graphical interface
jarvis init --preset <name> --force  # Initialize with preset
jarvis ask "<question>"         # Ask a question
jarvis digest --fresh           # Generate daily briefing
```

**Skill Management:**
```bash
jarvis skill install hermes:arxiv          # Install skill
jarvis skill sync hermes --category research  # Sync skills
jarvis ask "Use the code-explainer skill to explain this code: ..."
jarvis optimize skills --policy dspy         # Optimize skills
jarvis bench skills --max-samples 5 --seeds 42  # Benchmark skills
```

**Agent Management:**
```bash
jarvis agent list               # List available agents
jarvis agent start <name>      # Start an agent
jarvis agent stop <name>       # Stop an agent
jarvis agent status            # Show agent status
```

### 4.3 Architecture Details

#### Rust Extension
- Performance-critical components in Rust
- Background downloading and processing
- Optimized for efficiency

#### Model Support
- **Local Models:** Via Ollama
- **Cloud Models:** OpenAI, Anthropic, Google, etc.
- **Model Selection:** Automatic based on task
- **Fallback:** Cloud when local insufficient

#### Trace System
- **Trace Collection:** Records all agent interactions
- **Trace Storage:** Local database
- **Trace Analysis:** For optimization and benchmarking
- **Trace-Based Learning:** Improves models from real usage

---

## 5. Strengths Analysis

### 5.1 What OpenJarvis Does Well

#### 1. Local-First Architecture ✅
- **Runs on personal devices** by default
- **Cloud is optional**, not required
- **Optimized for local execution**
- **Research-backed** efficiency improvements

#### 2. Modular Design ✅
- **Composable agents**
- **Reusable skills**
- **Extensible tools**
- **Plugin architecture**

#### 3. Research Focus ✅
- **Intelligence efficiency** as first-class concern
- **Benchmarking capabilities**
- **Learning loop** from trace data
- **Academic rigor** (Stanford SAIL)

#### 4. Multi-Platform Support ✅
- **macOS, Linux, WSL2, Windows**
- **Desktop GUI** applications
- **CLI interface**
- **Cross-platform** design

#### 5. Extensibility ✅
- **Skills system** for new capabilities
- **Plugin architecture** for tools
- **Custom agent** support
- **Open standard** (agentskills.io)

#### 6. Performance Optimization ✅
- **Energy, FLOPs, latency, cost** optimization
- **Rust extension** for performance
- **Efficient local execution**
- **Automatic model selection**

### 5.2 Technical Excellence

✅ **Local Models:** 88.7% of queries handled locally  
✅ **Efficiency:** 5.3× improvement from 2023-2025  
✅ **Research:** Backed by Stanford SAIL  
✅ **Community:** 13,579 stars, 3,255 forks  
✅ **Documentation:** Comprehensive guides and tutorials  
✅ **Testing:** Extensive test suite  

---

## 6. Weaknesses & Limitations

### 6.1 Architectural Limitations

❌ **No Security Sandboxing**
- Runs with user-level permissions
- No isolation between agents and system
- No capability-based authorization
- No audit trails

❌ **No OS Integration**
- Standalone application, not OS-integrated
- No D-Bus integration
- No system-level controls
- No desktop environment integration

❌ **No Deterministic Workflows**
- Agents can make arbitrary decisions
- No explicit workflow definitions
- No validation of agent outputs

❌ **Limited Multi-Agent Coordination**
- Agents operate independently
- No explicit orchestration layer
- No parent-child agent relationships

### 6.2 Functional Limitations

❌ **No Deep Security Features**
- No adversarial review
- No vulnerability scanning
- No capability validation

❌ **No System-Level Access**
- Cannot perform privileged operations
- No package management integration
- No service management
- No system monitoring

❌ **No User Customization Constraints**
- Users can create any agent
- No capability boundaries
- No approval workflows

❌ **No Audit System**
- No logging of agent actions
- No traceability
- No accountability

### 6.3 Platform Limitations

❌ **No Linux-Native Integration**
- Generic Linux support, not optimized for any desktop
- No Wayland-specific features
- No systemd integration
- No package manager integration

❌ **No Axiom-Specific Features**
- Not designed for Axiom's architecture
- No RepoSpine integration
- No ContextGit support
- No Warden integration

---

## 7. Comparison with Jarvis 0.1

### 7.1 Architectural Comparison

| Feature | OpenJarvis | Jarvis 0.1 | Notes |
|---------|------------|------------|-------|
| **Local-First** | ✅ Yes | ✅ Yes | Both prioritize local execution |
| **Cloud Fallback** | ✅ Yes | ✅ Yes | Both support cloud when needed |
| **Modular Agents** | ✅ Yes | ✅ Yes | Both use composable agents |
| **Skills/Tools** | ✅ Skills | ✅ MCP + Tools | Similar concepts |
| **Security Sandboxing** | ❌ No | ✅ Warden | Jarvis 0.1 has enterprise security |
| **OS Integration** | ❌ No | ✅ Yes | Jarvis 0.1 integrates with Axiom |
| **Capability Auth** | ❌ No | ✅ Yes | Jarvis 0.1 has explicit boundaries |
| **Deterministic Workflows** | ❌ No | ✅ Yes | Jarvis 0.1 has explicit workflows |
| **Multi-Agent Orchestration** | ❌ No | ✅ Yes | Jarvis 0.1 has parent orchestrator |
| **Audit System** | ❌ No | ✅ Yes | Jarvis 0.1 has complete audit |
| **D-Bus Integration** | ❌ No | ✅ Yes | Jarvis 0.1 uses Axiom's D-Bus |
| **RepoSpine Integration** | ❌ No | ✅ Yes | Jarvis 0.1 integrates with RepoSpine |
| **Wayland Support** | ❌ No | ✅ Yes | Jarvis 0.1 optimized for Wayland |

### 7.2 Capability Comparison

| Capability | OpenJarvis | Jarvis 0.1 | Notes |
|------------|------------|------------|-------|
| **Deep Research** | ✅ Yes | ✅ Yes | Both have research agents |
| **Code Assistance** | ✅ Yes | ✅ Yes | Both have code agents |
| **System Automation** | ❌ No | ✅ Yes | Jarvis 0.1 has automation agent |
| **Security Review** | ❌ No | ✅ Yes | Jarvis 0.1 has security agent |
| **System Monitoring** | ✅ Basic | ✅ Advanced | Jarvis 0.1 has performance agent |
| **Multi-Source Verification** | ✅ Yes | ✅ Enhanced | Jarvis 0.1 emphasizes verification |
| **User Customization** | ✅ Yes | ✅ Enhanced | Jarvis 0.1 has SKILL.md format |
| **Voice Interface** | ✅ Yes | ✅ Planned | Both support voice |
| **GUI Interface** | ✅ Yes | ✅ Planned | Both have graphical interfaces |

### 7.3 Design Philosophy Comparison

| Aspect | OpenJarvis | Jarvis 0.1 |
|--------|------------|------------|
| **Primary Goal** | Research platform | Production desktop |
| **Target Audience** | Researchers, developers | Axiom users, developers |
| **Security Model** | Trust user's environment | Zero-trust, sandboxed |
| **Extensibility** | Skills, plugins | MCP, SKILL.md, plugins |
| **OS Integration** | Standalone app | Deep OS integration |
| **Workflow Control** | Agent-driven | Explicit workflows |
| **Audit Requirements** | Optional | Mandatory |

---

## 8. Architectural Patterns to Adopt

### 8.1 Recommended Patterns from OpenJarvis

#### 1. Modular Agent Design
**Adopt:** Composable, single-purpose agents
**Implementation:**
- Built-in agents for research, code, security, automation, etc.
- Each agent has clear, narrow responsibility
- Agents can be combined for complex tasks

#### 2. Skills System
**Adopt:** Reusable capabilities that agents can use
**Implementation:**
- MCP servers as skills
- Tool catalog with versioned interfaces
- Skill discovery and invocation

#### 3. Local-First Execution
**Adopt:** Prefer local models, use cloud as fallback
**Implementation:**
- Ollama integration for local models
- Model router with local priority
- Cloud adapter for fallback

#### 4. Efficiency Optimization
**Adopt:** Treat energy, FLOPs, latency, cost as first-class
**Implementation:**
- Performance benchmarking
- Model selection based on task and efficiency
- Resource budgeting and tracking

#### 5. Preset System
**Adopt:** Pre-configured setups for common use cases
**Implementation:**
- Presets for different user types (developer, researcher, etc.)
- Quick-start configurations
- Customizable presets

### 8.2 Patterns to Enhance

#### 1. Add Security Sandboxing
**Enhancement:** Run all agents in Warden sandboxes
**Benefits:**
- Isolation between agents and system
- Capability-based authorization
- Fail-closed security model

#### 2. Add Deterministic Workflows
**Enhancement:** Explicit workflow definitions instead of agent-driven
**Benefits:**
- Predictable behavior
- Validation of agent outputs
- Auditability of workflows

#### 3. Add Multi-Agent Orchestration
**Enhancement:** Parent orchestrator for agent coordination
**Benefits:**
- Centralized control
- Capability delegation
- Resource management

#### 4. Add OS Integration
**Enhancement:** Deep integration with Axiom's infrastructure
**Benefits:**
- D-Bus integration for IPC
- RepoSpine for system context
- system-agentd for privileged operations
- Wayland optimization

#### 5. Add Complete Audit System
**Enhancement:** Comprehensive logging of all actions
**Benefits:**
- Traceability
- Accountability
- Security monitoring
- Debugging

---

## 9. Integration Opportunities

### 9.1 Potential Collaboration

**Option 1: Use OpenJarvis as Foundation**
- Fork OpenJarvis and add Axiom-specific features
- Pros: Leverage existing agent infrastructure
- Cons: May not fit Axiom's architecture perfectly
- Decision: **NOT RECOMMENDED** - Architectural differences too significant

**Option 2: Borrow Concepts, Build Custom**
- Adopt OpenJarvis's architectural patterns
- Build custom implementation optimized for Axiom
- Pros: Full control, perfect fit
- Cons: More development work
- Decision: **RECOMMENDED** ✅

**Option 3: Integration via MCP**
- Run OpenJarvis agents as MCP servers
- Connect to Jarvis 0.1 orchestrator
- Pros: Best of both worlds
- Cons: Complex integration
- Decision: **FUTURE CONSIDERATION**

### 9.2 Specific Components to Borrow

#### 1. Agent Definitions
**Borrow:** YAML-based agent configuration
**Adapt:** Convert to SKILL.md format with Axiom's requirements

#### 2. Tool Interface
**Borrow:** Unified tool calling interface
**Adapt:** Convert to MCP protocol with Axiom's contracts

#### 3. Model Router
**Borrow:** Local-first model selection
**Adapt:** Add Axiom's capability-based routing

#### 4. Benchmarking System
**Borrow:** Performance benchmarking
**Adapt:** Add Axiom's quality gates

---

## 10. Recommendations for Jarvis 0.1

### 10.1 Architecture Recommendations

1. **Adopt OpenJarvis's Modular Design**
   - [ ] Use composable, single-purpose agents
   - [ ] Implement skills/tools as reusable components
   - [ ] Support multiple execution modes (on-demand, scheduled, continuous)

2. **Enhance with Axiom-Specific Features**
   - [ ] Add Warden sandboxing for all execution
   - [ ] Implement capability-based authorization
   - [ ] Add deterministic workflow definitions
   - [ ] Integrate with Axiom's D-Bus infrastructure

3. **Add Missing Capabilities**
   - [ ] Security agent for adversarial review
   - [ ] System automation agent
   - [ ] Performance monitoring agent
   - [ ] User customization with SKILL.md

### 10.2 Implementation Recommendations

1. **Start with Core Infrastructure**
   - [ ] assistantd (parent orchestrator)
   - [ ] Policy engine
   - [ ] Audit system
   - [ ] Model router

2. **Implement Built-in Agents**
   - [ ] Research agent (similar to OpenJarvis deep_research)
   - [ ] Code agent (similar to OpenJarvis native_openhands)
   - [ ] Security agent (new)
   - [ ] Automation agent (new)
   - [ ] Context agent (RepoSpine integration)

3. **Add OpenJarvis-Inspired Features**
   - [ ] Preset system for quick setup
   - [ ] Skills system (via MCP)
   - [ ] Efficiency optimization
   - [ ] Trace-based learning (future)

### 10.3 Research Collaboration

1. **Contribute to OpenJarvis**
   - [ ] Submit bug fixes and improvements
   - [ ] Share benchmarking results
   - [ ] Collaborate on agent standards

2. **Learn from OpenJarvis Research**
   - [ ] Adopt intelligence efficiency metrics
   - [ ] Use their benchmarking methodology
   - [ ] Follow their paper for updates

3. **Differentiate Clearly**
   - [ ] Focus on security and OS integration
   - [ ] Target Axiom-specific use cases
   - [ ] Emphasize production readiness

---

## 11. Conclusion

### 11.1 Summary Findings

OpenJarvis is an **excellent research platform** that demonstrates **state-of-the-art local-first AI agent architecture**. It provides **valuable patterns and lessons** for Jarvis 0.1, but it has **different design goals** that create opportunities for differentiation.

**Key Lessons from OpenJarvis:**
1. ✅ **Local-first architecture** works for 88.7% of queries
2. ✅ **Modular agents** enable composability and extensibility
3. ✅ **Intelligence efficiency** (energy, FLOPs, latency, cost) matters
4. ✅ **Skills system** enables reuse and customization
5. ✅ **Preset system** reduces setup complexity
6. ✅ **Trace-based learning** improves models over time

**Key Opportunities for Jarvis 0.1:**
1. 🎯 **Add enterprise-grade security** (Warden sandboxing, capability auth)
2. 🎯 **Add deep OS integration** (D-Bus, RepoSpine, Wayland)
3. 🎯 **Add deterministic workflows** (explicit definitions, validation)
4. 🎯 **Add multi-agent orchestration** (parent-child relationships)
5. 🎯 **Add complete audit system** (traceability, accountability)

### 11.2 Strategic Positioning

**Jarvis 0.1 should position itself as:**

> **"OpenJarvis for production: A secure, OS-integrated, locally-optimized AI-native layer for the Axiom desktop."**

**Relationship with OpenJarvis:**
- **Complementary, not competitive** - Different design goals
- **Learn and adapt** - Adopt best practices and patterns
- **Collaborate** - Contribute to open standards and research
- **Differentiate** - Add Axiom-specific features and security

### 11.3 Next Steps

1. **Adopt OpenJarvis patterns** in Jarvis 0.1 architecture
2. **Enhance with Axiom-specific features** (security, OS integration)
3. **Implement 4-round reasoning framework** with sub-agent spawning
4. **Build Warden integration** for security
5. **Create SKILL.md format** for user-defined agents

---

## Appendix A: OpenJarvis Paper Summary

**Title:** OpenJarvis: Personal AI, On Personal Devices  
**Authors:** Jon Saad-Falcon, Avanika Narayan, Robby Manihani, Tanvir Bhathal, Herumb Shandilya, Hakki Orhun Akengin, Gabriel Bo, Andrew Park, Matthew Hart, Caia Costello, Chuan Li, Christopher Ré, Azalia Mirhoseini  
**Institution:** Hazy Research and Scaling Intelligence Lab, Stanford SAIL  
**Date:** May 2026  
**arXiv:** 2605.17172  
**URL:** https://arxiv.org/abs/2605.17172

### Key Contributions

1. **Framework for local-first personal AI**
   - Shared primitives for on-device agents
   - Evaluations treating efficiency as first-class
   - Learning loop from local trace data

2. **Intelligence Per Watt Research**
   - Local models handle 88.7% of single-turn queries
   - 5.3× efficiency improvement from 2023-2025
   - Energy, FLOPs, latency, cost as optimization targets

3. **Open Source Implementation**
   - Apache 2.0 license
   - Cross-platform support
   - Extensible architecture

---

## Appendix B: OpenJarvis vs Other Frameworks

| Framework | Local-First | Modular | Security | OS Integration | Target |
|-----------|-------------|---------|----------|----------------|--------|
| **OpenJarvis** | ✅ Yes | ✅ Yes | ❌ No | ❌ No | Researchers |
| **LangGraph** | ❌ No | ✅ Yes | ❌ No | ❌ No | Developers |
| **CrewAI** | ❌ No | ✅ Yes | ❌ No | ❌ No | Developers |
| **Microsoft Agent Framework** | ❌ No | ✅ Yes | ✅ Partial | ✅ Partial | Enterprise |
| **Jarvis 0.1** | ✅ Yes | ✅ Yes | ✅ Full | ✅ Full | Axiom Users |

---

## Document Metadata

- **Status:** COMPLETE
- **Version:** 1.0.0
- **Author:** Axiom AI Research Team
- **Date:** 2026-11-06
- **Last Updated:** 2026-11-06
- **Sources:** 
  - https://github.com/open-jarvis/OpenJarvis
  - https://openjarvis.stanford.edu/
  - https://arxiv.org/abs/2605.17172
  - https://open-jarvis.github.io/OpenJarvis/
- **Related Documents:**
  - [JARVIS_01_RESEARCH.md](JARVIS_01_RESEARCH.md)
  - [JARVIS_01_ARCHITECTURE.md](JARVIS_01_ARCHITECTURE.md)
  - [JARVIS_01_STONICAI_ANALYSIS.md](JARVIS_01_STONICAI_ANALYSIS.md)
  - [JARVIS_01_SUMMARY.md](JARVIS_01_SUMMARY.md)

---

**Note:** This document is part of the Jarvis 0.1 research series. For complete context, refer to the main research and architecture documents.
