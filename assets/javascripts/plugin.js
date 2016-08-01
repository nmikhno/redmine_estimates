$(document).ready(function(){

					var tableRows 	= $('#estimate-entries').find('tbody tr'),
						isHidden 	= true;
					
					// tableRows.each(toggleAcceptedEstimates);
					$('#accepted_estimates').on('click', toggleAcceptedEstimates);
					
					// hide all accepted by default
					tableRows.each(function(index, el){
						var tableRow = $(this);
						if( tableRow.data('isAccepted') ) tableRow.addClass('hidden');
					});
					
					updateStriping();

					function toggleAcceptedEstimates(){
						isHidden = !isHidden;
						console.log('is hidden', isHidden)
						tableRows.each(function(index, el){
							var tableRow = $(this);
							if( tableRow.data('isAccepted') ) tableRow.toggleClass('hidden');
						});

						updateStriping(tableRows);
					}

			      function updateStriping(rowsSelector){
						$("#estimate-entries").each(function() {   

						    $(this).not('thead tr').find("tr:visible:even").addClass("even").removeClass("odd");
						    	 
						    $(this).not('thead tr').find("tr:visible:odd").addClass("odd").removeClass("even");
						});
			        }

			});