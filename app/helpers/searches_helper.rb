module SearchesHelper
  def paginate_elastic results
    totalResults = results.results.total
    results_on_page = 10 # this needs to be a property.

    pages = totalResults / results_on_page
    if totalResults % results_on_page != 0
      pages += 1
    end


    # If page is not set then make page 1.
    page = params[:page].to_i
    if !params[:page]
      page = 1
    end

    # Sorry lots of wacky calculations to get the number of items before and after current page.
    maxPageAddition = 0
    if page - 6 < 1
      maxPageAddition = 6 - page
    end

    minPageAddition = 0
    if page + 4 > pages
      minPageAddition = (page + 4) - pages
    end

    minPage = page - 5 - minPageAddition > 1? page - 5 - minPageAddition : 1
    maxPage = page + 4 + maxPageAddition > pages ? pages : page+4+maxPageAddition

    searchParams = Hash.new
    searchParams[:page] = page
    searchParams[:minPage] = minPage
    searchParams[:maxPage] = maxPage
    searchParams[:totalPages] = pages
    if pages > 0
    	render 'searches/pagination', :searchParams => searchParams
    end
  end
end
