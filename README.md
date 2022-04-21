# type-builder

This thing takes data definitions from [Censys](https://search.censys.io/search/definitions) and outputs approximately equivalent go structs that can be used to unmarshal the json responses from the [api](https://search.censys.io/api).

Generated types for [this go API wrapper](https://github.com/elliotcubit/go-censys), which were then edited by hand.

This code isn't good or pretty, but it _is_ useful.

Example:

Input:

```
services.kubernetes.endpoints.name	text	
services.kubernetes.endpoints.self_link	text	
services.kubernetes.endpoints.subsets.addresses.hostname	text	
services.kubernetes.endpoints.subsets.addresses.ip	ip	
services.kubernetes.endpoints.subsets.addresses.node_name	text	
services.kubernetes.endpoints.subsets.ports.name	text	
services.kubernetes.endpoints.subsets.ports.port	unsigned_long	
services.kubernetes.endpoints.subsets.ports.protocol	text	
services.kubernetes.kubernetes_dashboard_found	boolean	True if the dashboard is running and accessible
services.kubernetes.nodes.addresses.address	keyword	Node address, IP/URL.
services.kubernetes.nodes.addresses.address_type	text	Node address type, one of Hostname, ExternalIP or InternalIP.
services.kubernetes.nodes.architecture	text	The Architecture reported by the node.
services.kubernetes.nodes.container_runtime_version	text	ContainerRuntime Version reported by the node through runtime remote API (e.g. docker://1.5.0).
services.kubernetes.nodes.images	text	List of container images on this node
services.kubernetes.nodes.kernel_version	text	Kernel Version reported by the node from 'uname -r' (e.g. 3.16.0-0.bpo.4-amd64).
services.kubernetes.nodes.kube_proxy_version	text	KubeProxy Version reported by the node.
services.kubernetes.nodes.kubelet_version	text	Kubelet Version reported by the node.
services.kubernetes.nodes.name	text	
services.kubernetes.nodes.operating_system	text	The Operating System reported by the node.
services.kubernetes.nodes.os_image	text	OS Image reported by the node from /etc/os-release (e.g. Debian GNU/Linux 7 (wheezy)).
services.kubernetes.pod_names	text	
services.kubernetes.roles.name	text	
services.kubernetes.roles.rules.api_groups	text	APIGroups is the name of the APIGroup that contains the resources. If multiple API groups are specified, any action requested against one of the enumerated resources in any API group will be allowed.
services.kubernetes.roles.rules.resources	text	Resources is a list of resources this rule applies to. ResourceAll represents all resources
services.kubernetes.roles.rules.verbs	text	Verbs is a list of Verbs that apply to ALL the ResourceKinds and AttributeRestrictions contained in this rule. VerbAll represents all kinds.
services.kubernetes.version_info.build_date	text	Date version was built.
services.kubernetes.version_info.compiler	text	Go Compiler used
services.kubernetes.version_info.git_commit	text	Git commit version built from.
services.kubernetes.version_info.git_tree_state	text	State of the tree when built.
services.kubernetes.version_info.git_version	text	
services.kubernetes.version_info.go_version	text	Version of GO used to build version.
services.kubernetes.version_info.major	text	Kubernetes major version
services.kubernetes.version_info.minor	text	Kubernetes minor version
services.kubernetes.version_info.platform	text	Platform compiled for
```

Output:

```
type Kubernetes struct {
	Endpoints Kubernetes_Endpoints `json:"endpoints"`
	KubernetesDashboardFound bool `json:"kubernetes_dashboard_found"`
	Nodes Kubernetes_Nodes `json:"nodes"`
	PodNames string `json:"pod_names"`
	Roles Kubernetes_Roles `json:"roles"`
	VersionInfo Kubernetes_VersionInfo `json:"version_info"`
}

type Kubernetes_VersionInfo struct {
	BuildDate string `json:"build_date"`
	Compiler string `json:"compiler"`
	GitCommit string `json:"git_commit"`
	GitTreeState string `json:"git_tree_state"`
	GitVersion string `json:"git_version"`
	GoVersion string `json:"go_version"`
	Major string `json:"major"`
	Minor string `json:"minor"`
	Platform string `json:"platform"`
}

type Kubernetes_Roles struct {
	Name string `json:"name"`
	Rules Kubernetes_Roles_Rules `json:"rules"`
}

type Kubernetes_Roles_Rules struct {
	ApiGroups string `json:"api_groups"`
	Resources string `json:"resources"`
	Verbs string `json:"verbs"`
}

type Kubernetes_Nodes struct {
	Addresses Kubernetes_Nodes_Addresses `json:"addresses"`
	Architecture string `json:"architecture"`
	ContainerRuntimeVersion string `json:"container_runtime_version"`
	Images string `json:"images"`
	KernelVersion string `json:"kernel_version"`
	KubeProxyVersion string `json:"kube_proxy_version"`
	KubeletVersion string `json:"kubelet_version"`
	Name string `json:"name"`
	OperatingSystem string `json:"operating_system"`
	OsImage string `json:"os_image"`
}

type Kubernetes_Nodes_Addresses struct {
	Address string `json:"address"`
	AddressType string `json:"address_type"`
}

type Kubernetes_Endpoints struct {
	Name string `json:"name"`
	SelfLink string `json:"self_link"`
	Subsets Kubernetes_Endpoints_Subsets `json:"subsets"`
}

type Kubernetes_Endpoints_Subsets struct {
	Addresses Kubernetes_Endpoints_Subsets_Addresses `json:"addresses"`
	Ports Kubernetes_Endpoints_Subsets_Ports `json:"ports"`
}

type Kubernetes_Endpoints_Subsets_Ports struct {
	Name string `json:"name"`
	Port uint64 `json:"port"`
	Protocol string `json:"protocol"`
}

type Kubernetes_Endpoints_Subsets_Addresses struct {
	Hostname string `json:"hostname"`
	Ip string `json:"ip"`
	NodeName string `json:"node_name"`
}
```
