desc '[TEST] Run Locust swarm against Preferences service in current cluster'
task :test_preferences => [:set_vars] do
  sh "#{@exekube_cmd} rake xk[' \
    xk down live/dev/locust && \
    sleep 30 && \
    TF_VAR_locust_target_host=http://preferences.$TF_VAR_domain_name \
    TF_VAR_locust_script=preferences.py \
    xk up live/dev/locust',skip_infra,skip_secret_mgmt]"
end

desc '[TEST] Run Locust swarm against Flowmanager service in current cluster'
task :test_flowmanager => [:set_vars] do
  sh "#{@exekube_cmd} rake xk[' \
    xk down live/dev/locust && \
    sleep 30 && \
    TF_VAR_locust_target_host=http://flowmanager.$TF_VAR_domain_name \
    TF_VAR_locust_script=flowmanager.py \
    TF_VAR_locust_users=30 \
    TF_VAR_locust_desired_total_rps=10 \
    TF_VAR_locust_desired_median_response_time=200 \
    TF_VAR_locust_desired_max_response_time=700 \
    xk up live/dev/locust',skip_infra,skip_secret_mgmt]"
end
