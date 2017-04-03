####################
### Repositories ###
####################

immutable Permission
	admin::Bool
	push::Bool
	pull::Bool
end

FieldTags.@tag immutable Repository
	id::Int64
	owner::User
	name::String
	fullName::String => json:"full_name"
	description::String
	private::Bool
	fork::Bool
	mirror::Bool
	htmlURL::String => json:"html_url"
	sshURL::String => json:"ssh_url"
	cloneURL::String => json:"clone_url"
	website::String
	stars::Int => json:"stars_count"
	forks::Int => json:"forks_count"
	watchers::Int => json:"watchers_count"
	openIssues::Int => json:"open_issues_count"
	defaultBranch::String => json:"default_branch"
	created::DateTime => json:"created_at,format:y-m-dTH:M:SZ"
	updated::DateTime => json:"updated_at,format:y-m-dTH:M:SZ"
	permissions::Nullable{Permission}
end


listMyRepos(c::Client) = getParsedResponse(Vector{Repository},c,Requests.get,"/user/repos")

listUserRepos(c::Client, user::String) = getParsedResponse(Vector{Repository},c,Requests.get,"/user/$(user)/repos")

listOrgRepos(c::Client, org::String) = getParsedResponse(Vector{Repository},c,Requests.get,"/orgs/$(org)/repos")

FieldTags.@tag immutable CreateRepoOption
	name::String
	description::Nullable{String}
	private::Nullable{Bool}
	autoInit::Nullable{Bool} => json:"auto_init"
	gitignores::Nullable{String}
	license::Nullable{String}
	readme::Nullable{String}
end

function CreateRepoOption(name; kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)

	args = [name]

	for field in fieldnames(CreateRepoOption)[2:end]
		push!(args,get(kwargsDict,field, fieldtype(CreateRepoOption,field)()))
	end

	CreateRepoOption(args...)
end

CreateRepoOption(name::String) = CreateRepoOption(name,map(x->fieldtype(CreateRepoOption,x)(),fieldnames(CreateRepoOption)[2:end])...)

createRepo(c::Client,opt::CreateRepoOption) = getParsedResponse(Repository,c,Requests.post,"/user/repos"; json = marshalJSON(opt))
createOrgRepo(c::Client, org::String, opt::CreateRepoOption) = getParsedResponse(Repository,c,Requests.post,"/org/$(org)/repos"; json = marshalJSON(opt))

getRepo(c::Client, owner::String, repo::String) = getParsedResponse(Repository,c,Requests.get,"/repos/$owner/$repo")

deleteRepo(c::Client, owner::String, repo::String) = (getResponse(Repository,c,Requests.delete,"/repos/$owner/$repo"); nothing)


FieldTags.@tag immutable MigrateRepoOption
	cloneAddr::String => json:"clone_addr"
	uid::Int
	repoName::String
	authUsername::Nullable{String} => json:"auth_username"
	authPassword::Nullable{String} => json:"auth_password"
	mirror::Nullable{Bool}
	private::Nullable{Bool}
	description::Nullable{String}
end

function MigrateRepoOption(cloneAddr,uid,name; kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)

	args = [cloneAddr,uid,name]

	for field in fieldnames(MigrateRepoOption)[4:end]
		push!(args,get(kwargsDict,field, fieldtype(MigrateRepoOption,field)()))
	end

	MigrateRepoOption(args...)
end


migrateRepo(c::Client, opt::MigrateRepoOption) = getParsedResponse(Repository,c,Requests.post,"/repos/migrate"; json = marshalJSON(opt))


