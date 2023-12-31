test_that("create_initial_view behaves correctly", {
  expr <- generate_random_tibble(50, 5)
  pos <- sample_grid_geometry(50, 10, 10)
  misty.views <- create_initial_view(expr)
  expect_length(misty.views, 2)
  expect_length(create_initial_view(data.frame(expr)), 2)
  expect_equal(misty.views[["intraview"]]$data, expr)
  expect_equal(nchar(misty.views[["misty.uniqueid"]]), 32)
})

test_that("add_juxtaview creates and adds a correct view", {
  expr <- generate_random_tibble(30, 5)
  pos <- sample_grid_geometry(30, 10, 10)
  misty.views <- create_initial_view(expr) %>%
    add_juxtaview(pos, neighbor.thr = sqrt(2))
  expect_length(misty.views, 3)

  # units with no neighbors should have 0 values for all variables in juxta
  expect_equal(which((rowSums(misty.views[[3]]$data) == 0)),
    which((rowSums(as.matrix(dist(pos)) <= sqrt(2)) - 1) == 0),
    ignore_attr = TRUE
  )
})

test_that("add_paraview creates and adds a correct view", {
  expr <- generate_random_tibble(100, 5)
  pos <- sample_grid_geometry(100, 10, 10)
  misty.views <- create_initial_view(expr) %>%
    add_paraview(pos, l = 2)
  expect_length(misty.views, 3)

  # nn approximation
  nn.views <- create_initial_view(expr) %>% add_paraview(pos, l = 2, nn = 20)
  nn.correlations <- cor(
    misty.views[["paraview.2"]]$data,
    nn.views[["paraview.2"]]$data
  )
  expect_equal(apply(nn.correlations, 2, max), diag(nn.correlations))

  # nystrom approximation
  nystrom.views <- create_initial_view(expr) %>%
    add_paraview(pos, l = 2, approx = 0.6)
  nystrom.correlations <- cor(
    misty.views[["paraview.2"]]$data,
    nystrom.views[["paraview.2"]]$data
  )
  expect_equal(apply(nystrom.correlations, 2, max), diag(nystrom.correlations))
})

test_that("create_view creates expected structure", {
  expr <- generate_random_tibble(30, 5)
  dummy.view <- create_view("dummy", expr, "dy")
  expect_length(dummy.view, 1)
  expect_length(dummy.view[[1]], 2)
  expect_equal(names(dummy.view), "dummy")
})

test_that("add_views works with created views", {
  expr <- generate_random_tibble(30, 5)
  expr2 <- generate_random_tibble(30, 5)
  expr3 <- generate_random_tibble(30, 5)
  dummy.view <- create_view("dummy", expr2, "dy")
  misty.views <- create_initial_view(expr) %>%
    add_views(c(dummy.view, create_view("dummy2", expr3)))
  expect_length(misty.views, 4)
  expect_setequal(
    names(misty.views),
    c("intraview", "misty.uniqueid", "dummy", "dummy2")
  )
})

test_that("remove_views removes only non-essential views", {
  expr <- generate_random_tibble(30, 5)
  pos <- sample_grid_geometry(30, 10, 10)
  misty.views <- create_initial_view(expr) %>%
    add_juxtaview(pos, 1.5) %>%
    add_paraview(pos, 2)
  expect_length(misty.views %>% remove_views("paraview.2"), 3)
  expect_length(misty.views %>% remove_views("intraview"), 4)
  expect_length(misty.views %>% remove_views("misty.uniqueid"), 4)
})

test_that("view composition works correctly", {
  expr <- generate_random_tibble(30, 5)
  pos <- sample_grid_geometry(30, 10, 10)
  new.expr <- generate_random_tibble(30, 5)
  misty.views <- create_initial_view(expr) %>%
    add_juxtaview(pos, 1.5) %>%
    add_paraview(pos, 2) %>%
    add_views(create_view("new", new.expr))
  expect_length(misty.views, 5)
})

test_that("views are cached and retrieved", {
  expr <- generate_random_tibble(30, 5)
  pos <- sample_grid_geometry(30, 10, 10)
  initial.view <- create_initial_view(expr)
  expect_message(
    initial.view %>% add_juxtaview(pos, 1.5, cached = TRUE),
    "Generating juxtaview"
  )
  expect_silent(initial.view %>% add_juxtaview(pos, 1.5, cached = TRUE))
  expect_message(
    initial.view %>% add_paraview(pos, 2, cached = TRUE),
    "Generating paraview"
  )
  expect_silent(initial.view %>% add_paraview(pos, 2, cached = TRUE))
  clear_cache()
})

test_that("add_paraview works with all distance families", {
  expr <- generate_random_tibble(30, 5)
  pos <- sample_grid_geometry(30, 10, 10)
  initial.view <- create_initial_view(expr)
  expect_error(misty.views <- initial.view %>% 
                 add_paraview(pos, 2, family="bar"))
  families <- c("gaussian", "exponential", "linear", "constant")
  expect_message(test.run <- 
  purrr::map(families, ~ initial.view %>% add_paraview(family=.x, pos, 2)),
  "Generating paraview")
  purrr::walk(test.run, ~ expect_length(.x, 3))
})
